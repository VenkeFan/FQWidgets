//
//  WLIMConnection.m
//  IMTest
//
//  Created by luxing on 2018/5/2.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import "WLIMConnection.h"
#import "GCDAsyncSocket.h"
#import "LuuLogger.h"
#import "WLIMEventDefines.h"

static const int WLTagHeader                = 1;
static const int WLTagBody                  = 2;
static const int WLConnectTimeout           = 30;
static const int WLConnectRetryDelay        = 10;
static const int WLHeartBeatCheck           = 8;
static const int WLWriteTimeout             = 5;
static const int WLHeadReadTimeout          = -1;
static const int WLBodyReadTimeout          = 10;
static const int WLHeartBeatInterval        = 30;

@interface WLIMConnection () <GCDAsyncSocketDelegate>
{
    dispatch_queue_t _socketQueue;
}

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) WLIMServerNode *serverNode;
@property (nonatomic, assign) NSUInteger heartBeatInterval;
@property (nonatomic, strong) WLIMUserConfig *config;
@property (nonatomic, strong) NSTimer *retryTimer;
@property (nonatomic, strong) NSTimer *heartBeatTimer;
@property (nonatomic, strong) NSTimer *checkTimer;

- (void)createSocket;
- (void)closeSocket;
- (void)handleError:(NSInteger)errCode;
- (void)triggerRetryConnect;
- (void)cancelTriggerRetryConnect;
- (void)triggerHeartBeat;
- (void)cancelTriggerHeartBeat;
- (void)triggerWriteFeedbackTimeout;
- (void)cancelTriggerWriteFeedbackTimeout;
- (void)sendBind;
- (void)sendHeartBeat;
- (void)reqHeadRead;
- (void)onWriteFeedbackTimeout;

@end

@implementation WLIMConnection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.heartBeatInterval = WLHeartBeatInterval;
        self.serverNode = [WLIMServerNode defaultServerNode];
        _socketQueue = dispatch_queue_create("welike.socket.queue", DISPATCH_QUEUE_SERIAL);
        _status = WLIMConnectionClosed;
    }
    return self;
}

- (void)dealloc
{
    [self disconnect];
}

#pragma mark public
- (void)connect
{
    if ([self.socket isConnected] == NO || _status != WLIMConnectionIdle)
    {
        [self disconnect];
        [self createSocket];
        NSError *error = nil;
        BOOL result = [self.socket connectToHost:self.serverNode.host onPort:self.serverNode.port withTimeout:WLConnectTimeout error:&error];
        [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   connect host=%@ port=%d return=%@", self.serverNode.host, self.serverNode.port, [NSNumber numberWithBool:result]] tag:IMLogTag];
        if (result == NO)
        {
            [self handleError:ERROR_IM_SOCKET_CLOSED];
        }
        else
        {
            _status = WLIMConnectionConnecting;
        }
    }
}

- (void)authFeedback:(NSInteger)errCode
{
    [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   authFeedback errCode=%ld status=%d", (long)errCode, _status] tag:IMLogTag];
    if (errCode == 200)
    {
        if (_status == WLIMConnectionAuthing)
        {
            _status = WLIMConnectionIdle;
            [self triggerHeartBeat];
            
            __weak typeof(self) weakSelf = self;
            dispatch_async(_socketQueue, ^{
                if ([weakSelf.delegate respondsToSelector:@selector(didConnected:)])
                {
                    [weakSelf.delegate didConnected:weakSelf];
                }
            });
        }
    }
    else if (errCode == 403 || errCode == 407 || errCode == 408)
    {
        [self handleError:ERROR_NETWORK_AUTH_TOKEN_INVALID];
    }
    else
    {
        [self handleError:ERROR_IM_SOCKET_CLOSED];
    }
}

- (void)disconnect
{
    _status = WLIMConnectionClosed;
    [self cancelTriggerRetryConnect];
    [self cancelTriggerHeartBeat];
    [self cancelTriggerWriteFeedbackTimeout];
    [self closeSocket];
}

- (void)writePacket:(id<WLIMPacking>)packet
{
    if ([self.socket isConnected] == YES)
    {
        NSData *data = [WLIMPacker packet:packet];
        [self.socket writeData:data withTimeout:WLWriteTimeout tag:0];
    }
    else
    {
        [self handleError:ERROR_IM_SOCKET_CLOSED];
    }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (self.socket == sock)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   didConnectToHost host=%@ port=%d status=%d", host, port, _status] tag:IMLogTag];
        if (_status == WLIMConnectionConnecting)
        {
            _status = WLIMConnectionAuthing;
            [self sendBind];
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    if (self.socket == sock)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   socketDidDisconnect error=%@", error] tag:IMLogTag];
        if (error != nil)
        {
            [self handleError:ERROR_IM_SOCKET_CLOSED];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (self.socket == sock)
    {
        [self cancelTriggerWriteFeedbackTimeout];

        if (tag == WLTagHeader)
        {
            uint32_t length = [data uint32Value];
            [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   didReadData read head data.lenght=%d", length] tag:IMLogTag];
            if (length > 0)
            {
                NSTimeInterval timeout = WLBodyReadTimeout * ((length >> 16) + 1);
                [self.socket readDataToLength:length withTimeout:timeout tag:WLTagBody];
            }
            else
            {
                [self reqHeadRead];
            }
        }
        else if (tag == WLTagBody)
        {
            [[LuuLogger share] log:@"+++++WLIMConnection+++++   didReadData read body" tag:IMLogTag];
            __weak typeof(self) weakSelf = self;
            dispatch_async(_socketQueue, ^{
                if ([weakSelf.delegate respondsToSelector:@selector(connect:didReceiveData:)])
                {
                    [weakSelf.delegate connect:self didReceiveData:data];
                }
            });
            [self reqHeadRead];
        }
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    if (self.socket == sock && [sock isConnected])
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   socketDidSecure status=%d", _status] tag:IMLogTag];
        if (_status == WLIMConnectionConnecting)
        {
            _status = WLIMConnectionAuthing;
            [self sendBind];
        }
    }
}

#pragma mark private
- (void)createSocket
{
    [self closeSocket];

    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.socket setIPv4PreferredOverIPv6:NO];
}

- (void)closeSocket
{
    if (self.socket != nil)
    {
        [self.socket disconnect];
        self.socket = nil;
    }
}

- (void)handleError:(NSInteger)errCode
{
    [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   handleError status=%d errCode=%ld", _status, (long)errCode] tag:IMLogTag];
    [self disconnect];
    __weak typeof(self) weakSelf = self;
    if (errCode == ERROR_NETWORK_AUTH_TOKEN_INVALID)
    {
        dispatch_async(_socketQueue, ^{
            if ([weakSelf.delegate respondsToSelector:@selector(connectTokenInvalid:)])
            {
                [weakSelf.delegate connectTokenInvalid:weakSelf];
            }
        });
    }
    else
    {
        dispatch_async(_socketQueue, ^{
            if ([weakSelf.delegate respondsToSelector:@selector(connect:errCode:)])
            {
                [weakSelf.delegate connect:weakSelf errCode:errCode];
            }
        });
        [self triggerRetryConnect];
    }
}

- (void)triggerRetryConnect
{
    [self cancelTriggerRetryConnect];
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   triggerRetryConnect" tag:IMLogTag];
    self.retryTimer = [NSTimer timerWithTimeInterval:WLConnectRetryDelay target:self selector:@selector(connect) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.retryTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTriggerRetryConnect
{
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   cancelTriggerRetryConnect" tag:IMLogTag];
    if (self.retryTimer)
    {
        [self.retryTimer invalidate];
        self.retryTimer = nil;
    }
}

- (void)triggerHeartBeat
{
    [self cancelTriggerHeartBeat];
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   triggerHeartBeat" tag:IMLogTag];
    self.heartBeatTimer = [NSTimer timerWithTimeInterval:self.heartBeatInterval target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTriggerHeartBeat
{
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   cancelTriggerHeartBeat" tag:IMLogTag];
    if (self.heartBeatTimer)
    {
        [self.heartBeatTimer invalidate];
        self.heartBeatTimer = nil;
    }
}

- (void)triggerWriteFeedbackTimeout
{
    [self cancelTriggerWriteFeedbackTimeout];
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   triggerWriteFeedbackTimeout" tag:IMLogTag];
    self.checkTimer = [NSTimer timerWithTimeInterval:WLHeartBeatCheck target:self selector:@selector(onWriteFeedbackTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.checkTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTriggerWriteFeedbackTimeout
{
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   cancelTriggerWriteFeedbackTimeout" tag:IMLogTag];
    if (self.checkTimer)
    {
        [self.checkTimer invalidate];
        self.checkTimer = nil;
    }
}

- (void)sendBind
{
    self.config = [WLIMUserConfig defaultUserConfig];
    [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   sendBind uid=%@ token=%@ version=%d la=%@", self.config.uid, self.config.token, self.config.version, self.config.la] tag:IMLogTag];
    WLIMConnMetaPacket *connMeta = [WLIMConnMetaPacket connMetaWithConfig:self.config];
    [self writePacket:connMeta];
    [self reqHeadRead];
}

- (void)sendHeartBeat
{
    [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnection+++++   sendHeartBeat status=%d", _status] tag:IMLogTag];
    if (_status == WLIMConnectionIdle)
    {
        WLIMHeartbeatPacket *heartbeat = [WLIMHeartbeatPacket heartbeatWithConfig:self.config];
        [self writePacket:heartbeat];
        [self triggerWriteFeedbackTimeout];
    }
}

- (void)reqHeadRead
{
    [self.socket readDataToLength:4 withTimeout:WLHeadReadTimeout tag:WLTagHeader];
}

- (void)onWriteFeedbackTimeout
{
    [[LuuLogger share] log:@"+++++WLIMConnection+++++   onWriteFeedbackTimeout" tag:IMLogTag];
    [self handleError:ERROR_IM_SOCKET_TIMEOUT];
}

@end
