//
//  WLIMListMessagesProvider.m
//  welike
//
//  Created by 刘斌 on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMListMessagesProvider.h"
#import "WLIMDatabaseManager.h"

@interface WLIMListMessagesProvider ()

@property (nonatomic, strong) WLIMMessage *cursor;
@property (nonatomic, weak) WLIMDatabaseManager *cache;

@end

@implementation WLIMListMessagesProvider

- (id)initWithCache:(WLIMDatabaseManager *)cache
{
    self = [super init];
    if (self)
    {
        self.cache = cache;
    }
    return self;
}

- (void)refreshMessagesWithSession:(WLIMSession *)session completed:(imListMessagesRefreshMessages)completed
{
    self.cursor = nil;
    __weak typeof(self) weakSelf = self;
    [self.cache listNewMessagesInSession:session.sessionId sessionType:session.sessionType countOfOnePage:IM_MESSAGES_ONE_PAGE completed:^(NSArray<WLIMMessage *> *messages) {
        if ([messages count] > 0)
        {
            weakSelf.cursor = [messages lastObject];
        }
        if (completed)
        {
            completed(messages);
        }
    }];
}

- (void)hisMessagesWithSession:(WLIMSession *)session completed:(imListMessagesRefreshMessages)completed
{
    if (self.cursor != nil)
    {
        __weak typeof(self) weakSelf = self;
        [self.cache listHisMessagesInSession:session.sessionId sessionType:session.sessionType cursorMid:self.cursor.messageId countOfOnePage:IM_MESSAGES_ONE_PAGE completed:^(NSArray<WLIMMessage *> *messages) {
            if ([messages count] > 0)
            {
                weakSelf.cursor = [messages lastObject];
            }
            if (completed)
            {
                completed(messages);
            }
        }];
    }
    else
    {
        if (completed)
        {
            completed(nil);
        }
    }
}

@end
