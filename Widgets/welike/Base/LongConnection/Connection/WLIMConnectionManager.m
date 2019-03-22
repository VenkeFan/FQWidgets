//
//  WLIMConnectionManager.m
//  IMTest
//
//  Created by luxing on 2018/5/2.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import "WLIMConnectionManager.h"
#import "WLIMDataHandler.h"
#import "WLIMSyncPacket.h"
#import "WLIMSyncFinPacket.h"
#import "BibiProtoApplication.pbobjc.h"
#import "WLAccountManager.h"
#import "LuuLogger.h"
#import "WLIMEventDefines.h"

@interface WLIMConnectionManager () <WLIMConnectionDelegate, WLIMDataHandlerDelegate>

@property (nonatomic, strong) WLIMConnection *connection;
@property (nonatomic, strong) WLIMDataHandler *dataHandler;
@property (nonatomic, strong) NSPointerArray *delegates;

- (void)fin:(long long)lv;
- (void)sync;
- (void)handlingEvents:(NSArray *)events;
- (BOOL)handlingEvent:(WLIMPacker *)packet;
- (void)broadcastReceiveNotifications;
- (void)broadcastTokenInvalid;
- (void)broadcastConnectSuccessed;
- (void)broadcastOneSendResult:(NSString *)mid errCode:(NSInteger)errCode;
- (void)broadcastAllSendResultsError:(NSInteger)errCode;
- (void)receiveEntries:(NSArray<SyncDataPacket_DataEntry*> *)entries last:(BOOL)last;

@end

@implementation WLIMConnectionManager

+ (WLIMConnectionManager *)instance
{
    static WLIMConnectionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WLIMConnectionManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.connection = [[WLIMConnection alloc] init];
        self.connection.delegate = self;
        
        self.dataHandler = [[WLIMDataHandler alloc] init];
        self.dataHandler.delegate = self;
        
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark - public
- (void)registerDelegate:(id<WLIMConnectionManagerDelegate>)delegate
{
    @synchronized (_delegates)
    {
        if ([_delegates containsObject:delegate] == NO)
        {
            [_delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLIMConnectionManagerDelegate>)delegate
{
    @synchronized (_delegates)
    {
        [_delegates removeObject:delegate];
    }
}

- (void)start
{
    [self.connection connect];
}

- (void)stop
{
    [self.connection disconnect];
}

- (void)sendPacket:(id<WLIMPacking>)packet
{
     [self.connection writePacket:packet];
}

#pragma mark - WLIMConnectionDelegate
- (void)didConnected:(WLIMConnection *)connect
{
     [self sync];
    [self broadcastConnectSuccessed];
}

- (void)connect:(WLIMConnection *)connect didReceiveData:(NSData *)data
{
    NSArray *events = [WLIMPacker unpackData:data];
    [self handlingEvents:events];
}

- (void)connectTokenInvalid:(WLIMConnection *)connect
{
    [self broadcastTokenInvalid];
}

- (void)connect:(WLIMConnection *)connect errCode:(NSInteger)errCode
{
    [self broadcastAllSendResultsError:errCode];
}

#pragma mark - WLIMDataHandlerDelegate
- (void)dataHandlerNewNotifications
{
    [[LuuLogger share] log:@"+++++WLIMConnectionManager+++++   dataHandlerNewNotifications" tag:IMLogTag];
    [self broadcastReceiveNotifications];
}

- (void)dataHandlerCompleted:(NSArray<SyncDataPacket_DataEntry*> *)entries lv:(long long)lv needSync:(BOOL)needSync last:(BOOL)last
{
    [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnectionManager+++++   dataHandlerCompleted entries.count=%ld lv=%lld needSync=%@ last=%@", (long)[entries count], lv, [NSNumber numberWithBool:needSync], [NSNumber numberWithBool:last]] tag:IMLogTag];
    if ([entries count] > 0)
    {
        [self receiveEntries:entries last:last];
    }
    
    if (lv != -1)
    {
        [self fin:lv];
    }
    
    if (needSync == YES)
    {
        [self sync];
    }
}

- (void)dataHandlerSendResult:(NSString *)mid errCode:(NSInteger)errCode
{
    [self broadcastOneSendResult:mid errCode:errCode];
}

#pragma mark - private
- (void)fin:(long long)lv
{
    SyncDataPacket_SyncMark *mark = [[SyncDataPacket_SyncMark alloc] init];
    mark.classified = MessageClassified_P2P;
    mark.lastVersion = lv;
    
    WLIMSyncFinPacket *packet = [[WLIMSyncFinPacket alloc] init];
    packet.syncMarksArray = [NSMutableArray array];
    [packet.syncMarksArray addObject:mark];
    packet.sendTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    [self.connection writePacket:packet];
}

- (void)sync
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLIMSyncPacket *syncPacket = [[WLIMSyncPacket alloc] init];
    syncPacket.fromUid = account.uid;
    syncPacket.seqId = 1;
    syncPacket.classifiedArray = [GPBEnumArray array];
    [syncPacket.classifiedArray addValue:MessageClassified_All];
    
    [self.connection writePacket:syncPacket];
}

- (void)handlingEvents:(NSArray *)events
{
    NSMutableArray *newEvents = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < events.count; i++)
    {
        WLIMPacker *packet = events[i];
        if ([self handlingEvent:packet] == NO)
        {
            [newEvents addObject:packet];
        }
    }
    if (newEvents.count > 0)
    {
        [self.dataHandler handleReceivedData:newEvents];
    }
}

- (BOOL)handlingEvent:(WLIMPacker *)packet
{
    switch (packet.header.type)
    {
        case WLEventConnAck:
        {
            ConnStatusPacket *body = [ConnStatusPacket parseFromData:packet.body error:nil];
            [self.connection authFeedback:body.code];
            [[LuuLogger share] log:[NSString stringWithFormat:@"+++++WLIMConnectionManager+++++   ConnStatusPacket %@",body] tag:IMLogTag];
            return YES;
        }
        case WLEventHeartBeat:
        {
            [[LuuLogger share] log:@"+++++WLIMConnectionManager+++++   heartbeat feedback" tag:IMLogTag];
            return YES;
        }
        default:
            return NO;
    }
}

- (void)broadcastReceiveNotifications
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLIMConnectionManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(imConnectionManagerReceiveNotifications)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate imConnectionManagerReceiveNotifications];
                });
            }
        }
    }
}

- (void)broadcastTokenInvalid
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLIMConnectionManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(imConnectionManagerTokenInvalid)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate imConnectionManagerTokenInvalid];
                });
            }
        }
    }
}

- (void)broadcastConnectSuccessed
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLIMConnectionManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(imConnectionManagerConnectSuccessed)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate imConnectionManagerConnectSuccessed];
                });
            }
        }
    }
}

- (void)broadcastOneSendResult:(NSString *)mid errCode:(NSInteger)errCode
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLIMConnectionManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(imConnectionManagerOneSendResult:errCode:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate imConnectionManagerOneSendResult:mid errCode:errCode];
                });
            }
        }
    }
}

- (void)broadcastAllSendResultsError:(NSInteger)errCode
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLIMConnectionManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(imConnectionManagerAllSendResultsError:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate imConnectionManagerAllSendResultsError:errCode];
                });
            }
        }
    }
}

- (void)receiveEntries:(NSArray<SyncDataPacket_DataEntry*> *)entries last:(BOOL)last
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLIMConnectionManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(imConnectionManagerReceiveEntries:last:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate imConnectionManagerReceiveEntries:entries last:last];
                });
            }
        }
    }
}

@end
