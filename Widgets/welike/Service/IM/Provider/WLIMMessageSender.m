//
//  WLIMMessageSender.m
//  welike
//
//  Created by 刘斌 on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMMessageSender.h"
#import "WLIMDatabaseManager.h"
#import "WLAccountManager.h"
#import "WLUploadManager.h"

@interface WLIMMessageSender () <WLUploadManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *messagesPool;
@property (nonatomic, strong) NSMutableDictionary *uploadTasks;
@property (nonatomic, weak) WLIMDatabaseManager *cache;

- (void)doSend:(WLIMMessage *)message session:(WLIMSession *)session;
- (void)handleErrorForMessage:(WLIMMessage *)message errCode:(NSInteger)errCode;

@end

@implementation WLIMMessageSender

- (id)initWithCache:(WLIMDatabaseManager *)cache
{
    self = [super init];
    if (self)
    {
        self.messagesPool = [NSMutableDictionary dictionary];
        self.uploadTasks = [NSMutableDictionary dictionary];
        self.cache = cache;
        [[AppContext getInstance].uploadManager registerDelegate:self];
    }
    return self;
}

- (void)sendMessage:(WLIMMessage *)message session:(WLIMSession *)session
{
    if ([self.messagesPool containForKey:message.messageId] == NO)
    {
        if ([session.remoteUid length] > 0)
        {
            [self.messagesPool setObject:message forKey:message.messageId];
            [self doSend:message session:session];
        }
        else
        {
            [self handleErrorForMessage:message errCode:ERROR_IM_SEND_MSG_RESOURCE_INVALID];
        }
    }
    else
    {
        [self handleErrorForMessage:message errCode:ERROR_IM_DUPLICATE_SEND_MSG];
    }
}

- (void)cancelAllSendingMessages
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.uploadTasks removeAllObjects];
        [self.messagesPool removeAllObjects];
    });
}

- (void)handleOneMessageSentResult:(NSString *)mid errCode:(NSInteger)errCode
{
    WLIMMessage *message = [self.messagesPool objectForKey:mid];
    if (message != nil)
    {
        if (errCode == ERROR_SUCCESS)
        {
            NSMutableDictionary *urls = [NSMutableDictionary dictionary];
            if ([message isKindOfClass:[WLIMPicMessage class]])
            {
                WLIMPicMessage *picMessage = (WLIMPicMessage *)message;
                if ([picMessage.picUri length] > 0)
                {
                    [urls setObject:picMessage.picUri forKey:IM_MESSAGE_COL_PIC];
                }
            }
            [self.cache refreshSendMessageResult:mid sessionId:message.sessionId sessionType:message.sessionType messageTime:message.time isGreet:message.isGreet status:WLIMMessageStatusSent urls:urls];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.messagesPool removeObjectForKey:message.messageId];
                if ([weakSelf.delegate respondsToSelector:@selector(onIMSenderOneMessageSentResult:errCode:)])
                {
                    [weakSelf.delegate onIMSenderOneMessageSentResult:message errCode:errCode];
                }
            });
        }
        else
        {
            [self handleErrorForMessage:message errCode:errCode];
        }
    }
}

#pragma mark - WLUploadManagerDelegate
- (void)onUploadingKey:(NSString *)objectKey completed:(NSString *)url
{
    NSString *messageId = [self.uploadTasks objectForKey:objectKey];
    if ([messageId length] > 0)
    {
        [self.uploadTasks removeObjectForKey:objectKey];
        WLIMMessage *message = [self.messagesPool objectForKey:messageId];
        if (message != nil)
        {
            if ([message isKindOfClass:[WLIMPicMessage class]] == YES)
            {
                ((WLIMPicMessage *)message).picUri = url;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(willSendMessage:)])
                {
                    [self.delegate willSendMessage:message];
                }
            });
        }
    }
}

- (void)onUploadingKey:(NSString *)objectKey failed:(NSInteger)errCode
{
    NSString *messageId = [self.uploadTasks objectForKey:objectKey];
    if ([messageId length] > 0)
    {
        [self.uploadTasks removeObjectForKey:objectKey];
        WLIMMessage *message = [self.messagesPool objectForKey:messageId];
        if (message != nil)
        {
            [self handleErrorForMessage:message errCode:errCode];
        }
    }
}

- (void)onUploadingKey:(NSString *)objectKey process:(CGFloat)process
{
    NSString *messageId = [self.uploadTasks objectForKey:objectKey];
    if ([messageId length] > 0)
    {
        WLIMMessage *message = [self.messagesPool objectForKey:messageId];
        if (message != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onIMSenderOneMessage:process:)])
                {
                    [self.delegate onIMSenderOneMessage:messageId process:process];
                }
            });
        }
    }
}

#pragma mark - private
- (void)doSend:(WLIMMessage *)message session:(WLIMSession *)session
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    message.sessionName = session.nickName;
    message.sessionHead = session.head;
    message.sessionType = session.sessionType;
    message.remoteUid = session.remoteUid;
    message.senderNickName = account.nickName;
    message.senderHead = account.headUrl;
    [self.cache sendMessage:message session:session completed:nil];
    
    if (message.type == WLIMMessageTypeTxt)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(willSendMessage:)])
            {
                [self.delegate willSendMessage:message];
            }
        });
    }
    else if (message.type == WLIMMessageTypePic)
    {
        WLIMPicMessage *picMessage = (WLIMPicMessage *)message;
        if ([picMessage.localFileName length] > 0)
        {
            NSString *objectKey = [[AppContext getInstance].uploadManager uploadWithFileName:picMessage.localFileName objectType:UPLOAD_TYPE_IMG];
            if ([objectKey length] > 0)
            {
                [self.uploadTasks setObject:message.messageId forKey:objectKey];
            }
            else
            {
                [self handleErrorForMessage:message errCode:ERROR_IM_SEND_MSG_RESOURCE_FAILED];
            }
        }
        else
        {
            [self handleErrorForMessage:message errCode:ERROR_IM_SEND_MSG_RESOURCE_INVALID];
        }
    }
}

- (void)handleErrorForMessage:(WLIMMessage *)message errCode:(NSInteger)errCode
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messagesPool removeObjectForKey:message.messageId];
        if ([weakSelf.delegate respondsToSelector:@selector(onIMSenderOneMessageSentResult:errCode:)])
        {
            [weakSelf.delegate onIMSenderOneMessageSentResult:message errCode:errCode];
        }
    });
}

@end
