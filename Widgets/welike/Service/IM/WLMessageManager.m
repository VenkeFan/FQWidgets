//
//  WLMessageManager.m
//  IMTest
//
//  Created by luxing on 2018/5/6.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import "WLMessageManager.h"
#import "WLIMDatabaseManager.h"
#import "WLIMInterceptor.h"
#import "WLIMListMessagesProvider.h"
#import "WLIMMessageSender.h"
#import "WLAccountManager.h"
#import "WLUser.h"
#import "WLIMCommon.h"
#import "WLIMEventDefines.h"

@interface WLMessageManager () <WLIMInterceptorDelegate, WLIMMessageSenderDelegate>

@property (nonatomic, strong) WLIMDatabaseManager *cacheManager;
@property (nonatomic, strong) WLIMInterceptor *interceptor;  //管理长连接的
@property (nonatomic, strong) WLIMListMessagesProvider *listMessagesProvider;
@property (nonatomic, strong) WLIMMessageSender *sender;
@property (nonatomic, strong) NSPointerArray *delegates;
@property (nonatomic, weak) id<WLMessageManagerSendDelegate> sendDelegate;
@property (nonatomic, strong) WLIMSession *currentSession;

- (void)broadcastReceivedMessages:(NSArray<WLIMMessage*> *)messages sid:(NSString *)sid;
- (void)broadcastSessionsUpdated:(NSArray<WLIMSession*> *)sessions;
- (void)broadcastNewMessagesCountChanged;
+ (NSArray *)filterMessages:(NSArray *)sourceList withinSid:(NSString *)sid;

@end

@implementation WLMessageManager

+ (WLMessageManager *)instance
{
    static WLMessageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WLMessageManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.cacheManager = [[WLIMDatabaseManager alloc] init];
        self.interceptor = [[WLIMInterceptor alloc] init];
        self.listMessagesProvider = [[WLIMListMessagesProvider alloc] initWithCache:self.cacheManager];
        self.sender = [[WLIMMessageSender alloc] initWithCache:self.cacheManager];
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark - public
- (void)registerDelegate:(id<WLMessageManagerReceivedDelegate>)delegate
{
    @synchronized (_delegates)
    {
        if ([_delegates containsObject:delegate] == NO)
        {
            [_delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLMessageManagerReceivedDelegate>)delegate
{
    @synchronized (_delegates)
    {
        [_delegates removeObject:delegate];
    }
}

- (void)openWithUid:(NSString *)uid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:kDatabasePath];
    [LuuUtils createDirectory:databasePath];
    NSString *dbName = [NSString stringWithFormat:@"welike_im_%@.db", uid];
    NSString *dbFileName = [databasePath stringByAppendingPathComponent:dbName];
    [self.cacheManager openDatabase:dbFileName];
}

- (void)close
{
    [self.cacheManager closeDatabase];
}

- (void)restart
{
    self.interceptor.delegate = self;
    self.sender.delegate = self;
    [self.interceptor restart];
}

- (void)stop
{
    [self.interceptor stop];
    self.sender.delegate = nil;
    self.interceptor.delegate = nil;
}

- (void)hasUnreadMessagesAndCompleted:(imHasUnread)completed
{
    [self.cacheManager hasUnreadMessagesAndCompleted:^(BOOL has) {
        if (completed)
        {
            completed(has);
        }
    }];
}

- (void)goInSingleSessionWithUser:(WLUser *)user sendDelegate:(id<WLMessageManagerSendDelegate>)sendDelegate completed:(imSessionGoInSession)completed
{
    __weak typeof(self) weakSelf = self;
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    NSString *myUid = account.uid;
    NSString *uid = user.uid;
    NSString *sid = [WLIMSession buildSessionIdWithUid1:myUid uid2:uid];
    [self goInSingleSessionWithSid:sid sendDelegate:sendDelegate completed:^(WLIMSession *session) {
        if (session != nil)
        {
            if (completed)
            {
                completed(session);
            }
        }
        else
        {
            WLIMSession *session = [[WLIMSession alloc] init];
            session.sessionId = sid;
            session.nickName = user.nickName;
            session.head = user.headUrl;
            session.msgType = WLIMMessageTypeUnknown;
            session.sessionType = WLIMSessionTypeP2P;
            session.unreadCount = 0;
            if (user.type == WELIKE_USER_TYPE_OFFICIAL)
            {
                session.enableChat = NO;
                session.visableChat = NO;
            }
            else
            {
                session.enableChat = YES;
                session.visableChat = YES;
            }
            session.time = 0;
            session.greet = NO;
            weakSelf.currentSession = session;
            if (completed)
            {
                completed(session);
            }
        }
    }];
}

- (void)goInSingleSessionWithSid:(NSString *)sid sendDelegate:(id<WLMessageManagerSendDelegate>)sendDelegate completed:(imSessionGoInSession)completed
{
    __weak typeof(self) weakSelf = self;
    NSSet<NSString *> *sids = [NSSet setWithObject:sid];
    self.sendDelegate = sendDelegate;
    [self.cacheManager getSessions:sids completed:^(NSArray<WLIMSession *> *sessions) {
        if ([sessions count] > 0)
        {
            [weakSelf.cacheManager clearSessionUnreadCount:sid completed:^(NSInteger count) {
                [self broadcastNewMessagesCountChanged];
            }];
            weakSelf.currentSession = sessions[0];
            weakSelf.currentSession.unreadCount = 0;
            if (completed)
            {
                completed(weakSelf.currentSession);
            }
        }
        else
        {
            if (completed)
            {
                completed(nil);
            }
        }
    }];
}

- (void)exitSingleSession:(WLIMSession *)session
{
    self.sendDelegate = nil;
    self.currentSession = nil;
}

- (void)listAllSessionsWithGreet:(BOOL)greet completed:(imSessionListAllSessions)completed
{
    [self.cacheManager listAllSessionsByGreet:greet completed:^(NSArray<WLIMSession *> *sessions) {
        if (completed)
        {
            completed(sessions, greet);
        }
    }];
}

- (void)removeSession:(WLIMSession *)session
{
    [self.cacheManager deleteSession:session];
    [self broadcastNewMessagesCountChanged];
}

- (void)refreshMessagesAndCompleted:(imChatRefreshMessages)completed
{
    if (self.currentSession != nil)
    {
        [self.listMessagesProvider refreshMessagesWithSession:self.currentSession completed:^(NSArray<WLIMMessage *> *messages) {
            if (completed)
            {
                completed(messages, self.currentSession.sessionId);
            }
        }];
    }
    else
    {
        if (completed)
        {
            completed(nil, nil);
        }
    }
}

- (void)hisMessagesAndCompleted:(imChatRefreshMessages)completed
{
    if (self.currentSession != nil)
    {
        [self.listMessagesProvider hisMessagesWithSession:self.currentSession completed:^(NSArray<WLIMMessage *> *messages) {
            if (completed)
            {
                completed(messages, self.currentSession.sessionId);
            }
        }];
    }
    else
    {
        if (completed)
        {
            completed(nil, nil);
        }
    }
}

- (void)sendMessage:(WLIMMessage *)message
{
    if (self.currentSession != nil)
    {
        [self.sender sendMessage:message session:self.currentSession];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.sendDelegate respondsToSelector:@selector(onIMOneSendResult:errCode:)])
            {
                [self.sendDelegate onIMOneSendResult:message errCode:ERROR_IM_SEND_MSG_RESOURCE_INVALID];
            }
        });
    }
}

- (void)cancelAllSendingMessages
{
    [self.sender cancelAllSendingMessages];
}

#pragma mark - WLIMInterceptorDelegate
- (void)onIMAdapterReceivedMessages:(NSArray<WLIMMessage*> *)messages last:(BOOL)last
{
    [self.cacheManager insertReceivedMessages:messages last:last completed:^(NSArray<WLIMMessage *> *newMessages, NSSet<NSString *> *sids, BOOL last) {
        if ([newMessages count] > 0)
        {
            if (self.currentSession != nil)
            {
                [self.cacheManager clearSessionUnreadCount:self.currentSession.sessionId completed:^(NSInteger count) {
                    [self broadcastNewMessagesCountChanged];
                }];
                
                NSArray *messagesInSid = [WLMessageManager filterMessages:newMessages withinSid:self.currentSession.sessionId];
                if ([messagesInSid count] > 0)
                {
                    [self broadcastReceivedMessages:messagesInSid sid:self.currentSession.sessionId];
                }
            }
            else
            {
                [self broadcastNewMessagesCountChanged];
            }
            
            [self.cacheManager getSessions:sids completed:^(NSArray<WLIMSession *> *sessions) {
                if ([sessions count] > 0)
                {
                    [self broadcastSessionsUpdated:sessions];
                }
            }];
        }
    }];
}

- (void)onIMAdapterOneMessageSentResult:(NSString *)mid errCode:(NSInteger)errCode
{
    [self.sender handleOneMessageSentResult:mid errCode:errCode];
}

- (void)onIMAdapterAllMessagesSentResultsError:(NSInteger)errCode
{
    if ([self.sendDelegate respondsToSelector:@selector(onIAllMSendMessagesError:)])
    {
        [self.sendDelegate onIAllMSendMessagesError:errCode];
    }
}

#pragma mark - WLIMMessageSenderDelegate
- (void)willSendMessage:(WLIMMessage *)message
{
    [self.interceptor sendMessage:message];
}

- (void)onIMSenderOneMessage:(NSString *)mid process:(CGFloat)process
{
    if ([self.sendDelegate respondsToSelector:@selector(onIMSendProcess:process:)])
    {
        [self.sendDelegate onIMSendProcess:mid process:process];
    }
}

- (void)onIMSenderOneMessageSentResult:(WLIMMessage *)message errCode:(NSInteger)errCode
{
    if ([self.sendDelegate respondsToSelector:@selector(onIMOneSendResult:errCode:)])
    {
        [self.sendDelegate onIMOneSendResult:message errCode:errCode];
    }
}

#pragma mark - private
- (void)broadcastReceivedMessages:(NSArray<WLIMMessage*> *)messages sid:(NSString *)sid
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLMessageManagerReceivedDelegate> delegate = [self.delegates pointerAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(onIMReceivedMessages:sid:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onIMReceivedMessages:messages sid:sid];
                });
            }
        }
    }
}

- (void)broadcastSessionsUpdated:(NSArray<WLIMSession*> *)sessions
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLMessageManagerReceivedDelegate> delegate = [self.delegates pointerAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(onIMSessionsUpdated:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onIMSessionsUpdated:sessions];
                });
            }
        }
    }
}

- (void)broadcastNewMessagesCountChanged
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLMessageManagerReceivedDelegate> delegate = [self.delegates pointerAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(onIMNewMessagesCountChanged)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onIMNewMessagesCountChanged];
                });
            }
        }
    }
}

+ (NSArray *)filterMessages:(NSArray *)sourceList withinSid:(NSString *)sid
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:[sourceList count]];
    for (NSInteger i = 0; i < [sourceList count]; i++)
    {
        WLIMMessage *message = [sourceList objectAtIndex:i];
        if ([message.sessionId isEqualToString:sid] == YES)
        {
            [list addObject:message];
        }
    }
    return list;
}

- (void)refreshUser:(WLUser *)user
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if (account != nil) {
        [self.cacheManager refreshUser:user completed:^(WLUser *user) {
            [self broadcastUserChanged:user];
        }];
    } else {
        [self broadcastUserChanged:user];
    }
}

- (void)broadcastUserChanged:(WLUser *)user
{
    if (self.currentSession == nil) {
        return;
    }
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLMessageManagerReceivedDelegate> delegate = [self.delegates pointerAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(onUserChanged:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onUserChanged:user];
                });
            }
        }
    }
}

@end
