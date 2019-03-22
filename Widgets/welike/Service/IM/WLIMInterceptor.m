//
//  WLIMInterceptor.m
//  welike
//
//  Created by 刘斌 on 2018/5/19.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMInterceptor.h"
#import "WLIMConnectionManager.h"
#import "BibiProtoApplication.pbobjc.h"
#import "WLIMEventDefines.h"

@interface WLIMInterceptor () <WLIMConnectionManagerDelegate>
{
    dispatch_queue_t _queue;
}

@end

@implementation WLIMInterceptor

- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("welike.im.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)restart
{
    [[WLIMConnectionManager instance] registerDelegate:self];
    [[WLIMConnectionManager instance] start];
}

- (void)stop
{
    [[WLIMConnectionManager instance] unregister:self];
    [[WLIMConnectionManager instance] stop];
}

- (void)sendMessage:(WLIMMessage *)message
{
    [[WLIMConnectionManager instance] sendPacket:message];
}

#pragma mark - WLIMConnectionManagerDelegate
- (void)imConnectionManagerReceiveEntries:(NSArray<SyncDataPacket_DataEntry*> *)entries last:(BOOL)last
{
    if ([entries count] > 0)
    {
        __weak typeof(self) weakSelf = self;
        NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[entries count]];
        dispatch_async(_queue, ^{
            for (NSInteger i = 0; i < [entries count]; i++)
            {
                SyncDataPacket_DataEntry *enrty = [entries objectAtIndex:i];
                if (enrty.type == WLEventMsgText)
                {
                    WLIMTextMessage *textMessage = (WLIMTextMessage *)[WLIMTextMessage parseFromBody:enrty.body];
                    textMessage.status = WLIMMessageStatusReceived;
                    [messages addObject:textMessage];
                }
                else if (enrty.type == WLEventMsgPic)
                {
                    WLIMPicMessage *picMessage = (WLIMPicMessage *)[WLIMPicMessage parseFromBody:enrty.body];
                    picMessage.status = WLIMMessageStatusReceived;
                    [messages addObject:picMessage];
                }
                else if (enrty.type == WLEventMsgNotice)
                {
                    WLIMSystemMessage *sysMessage = (WLIMSystemMessage *)[WLIMSystemMessage parseFromBody:enrty.body];
                    sysMessage.status = WLIMMessageStatusReceived;
                    [messages addObject:sysMessage];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onIMAdapterReceivedMessages:last:)])
                {
                    [weakSelf.delegate onIMAdapterReceivedMessages:messages last:last];
                }
            });
        });
    }
}

- (void)imConnectionManagerOneSendResult:(NSString *)mid errCode:(NSInteger)errCode
{
    if ([self.delegate respondsToSelector:@selector(onIMAdapterOneMessageSentResult:errCode:)])
    {
        [self.delegate onIMAdapterOneMessageSentResult:mid errCode:errCode];
    }
}

- (void)imConnectionManagerAllSendResultsError:(NSInteger)errCode
{
    if ([self.delegate respondsToSelector:@selector(onIMAdapterAllMessagesSentResultsError:)])
    {
        [self.delegate onIMAdapterAllMessagesSentResultsError:errCode];
    }
}

@end
