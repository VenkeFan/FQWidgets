//
//  WLMessageGroup.m
//  welike
//
//  Created by luxing on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageGroup.h"

#define FifteenMinute (15*60*1000)

@interface WLMessageGroup ()

@property (nonatomic, strong) NSMutableArray<WLMessageGroup *> *subGroups;

@property (nonatomic, strong) NSMutableArray<WLIMMessage *> *messages;

@property (nonatomic, strong) NSMutableDictionary *messageDic;

@property (nonatomic, assign) NSRange range;

@end

@implementation WLMessageGroup


//+ (NSArray<WLMessageGroup *> *)groups:(NSArray<WLMessageGroup *> *)messageGroups mergeMessages:(NSArray<WLIMMessage *> *)messages
//{
//    NSArray<WLMessageGroup*> *newGroups = [WLMessageGroup groupsWithMessages:messages];
//    return [WLMessageGroup groups:messageGroups mergeGroups:newGroups];
//}
//
//+ (NSArray<WLMessageGroup*> *)groups:(NSArray<WLMessageGroup*> *)oldGroups mergeGroups:(NSArray<WLMessageGroup*> *)newGroups
//{
//    NSInteger i = 0;
//    NSInteger j = 0;
//    NSMutableArray *allGroups = [NSMutableArray arrayWithCapacity:20];
//    while (i < oldGroups.count && j < newGroups.count) {
//        WLMessageGroup *oldGroup = oldGroups[i];
//        WLMessageGroup *newGroup = newGroups[j];
//        NSInteger result = [oldGroup compareGroup:newGroup];
//        if (result == 0) {
//            WLMessageGroup *bothGroup = [self group:oldGroup mergeGroup:newGroup];
//            if (bothGroup != nil) {
//                [allGroups addObject:bothGroup];
//            }
//            i++;
//            j++;
//        } else if(result < 0){
//            [allGroups addObject:oldGroups[i]];
//            i++;
//        } else {
//            [allGroups addObject:newGroups[j]];
//            j++;
//        }
//    }
//    while (i < oldGroups.count) {
//        [allGroups addObject:oldGroups[i]];
//        i++;
//    }
//    while (j < newGroups.count) {
//        [allGroups addObject:newGroups[j]];
//        j++;
//    }
//    return allGroups;
//}
//
//+ (NSArray<WLMessageGroup*> *)groupsWithMessages:(NSArray *)messages
//{
//    NSMutableArray *newGroups = [NSMutableArray arrayWithCapacity:20];
//    WLMessageGroup *newGroup = nil;
//    for (NSInteger i = 0; i < messages.count; i++) {
//        WLIMMessage *message = messages[i];
//        if (newGroup == nil) {
//            newGroup = [[WLMessageGroup alloc] init];
//            [newGroups addObject:newGroup];
//        }
//        if (![newGroup appendMessage:message]) {
//            [self groups:newGroups appendGroup:newGroup];
//            newGroup = nil;
//        }
//    }
//    return newGroups;
//}
//
//+ (void)groups:(NSMutableArray<WLMessageGroup*> *)groups appendGroup:(WLMessageGroup *)group
//{
//    NSInteger index = 0;
//    for (NSInteger i = groups.count-1; i >= 0; i--) {
//        WLMessageGroup *oldGroup = groups[i];
//        NSInteger result = [oldGroup compareGroup:group];
//        if (result == 0) {
//            [self group:oldGroup mergeGroup:group];
//        } else if(result < 0){
//            index = i;
//            break;
//        }
//    }
//    if (index == groups.count-1) {
//        [groups addObject:group];
//    } else if (index == 0) {
//        [groups insertObject:group atIndex:0];
//    } else {
//        [groups insertObject:group atIndex:index+1];
//    }
//}
//
//- (NSInteger)compareGroup:(WLMessageGroup *)group
//{
//    if (self.endTime+FifteenMinute < group.startTime) {
//        return -1;
//    } else if (group.endTime+FifteenMinute < self.startTime) {
//        return 1;
//    } else {
//        return 0;
//    }
//}
//
//+ (WLMessageGroup *)group:(WLMessageGroup *)oldGroup mergeGroup:(WLMessageGroup *)newGroup
//{
//    NSInteger i = 0;
//    NSInteger j = 0;
//    NSMutableArray *allMessages = [NSMutableArray arrayWithCapacity:20];
//    while (i < oldGroup.messages.count && j < newGroup.messages.count) {
//        WLIMMessage *oldMessage = [oldGroup messageAtIndex:i];
//        WLIMMessage *newMessage = [newGroup messageAtIndex:j];
//        if (oldMessage.time <= newMessage.time) {
//            [allMessages addObject:oldMessage];
//            i++;
//        } else {
//            [allMessages addObject:newMessage];
//            j++;
//        }
//    }
//    while (i < oldGroup.messages.count) {
//        [allMessages addObject:oldGroup.messages[i]];
//        i++;
//    }
//    while (j < newGroup.messages.count) {
//        [allMessages addObject:newGroup.messages[j]];
//        j++;
//    }
//    if (allMessages > 0) {
//        WLMessageGroup *bothGroup = [[WLMessageGroup alloc] init];
//        bothGroup.messages=allMessages;
//        WLIMMessage *first = allMessages[0];
//        bothGroup.startTime = first.time;
//        WLIMMessage *last = [allMessages lastObject];
//        bothGroup.endTime = last.time;
//        return bothGroup;
//    }
//    return nil;
//}
//
//- (WLIMMessage *)messageAtIndex:(NSUInteger)index
//{
//    if (index < self.messages.count) {
//        return [self.messages objectAtIndex:index];
//    }
//    return nil;
//}
//
//- (BOOL)appendMessage:(WLIMMessage *)message
//{
//    if (self.messages == nil) {
//        self.messages = [NSMutableArray arrayWithCapacity:20];
//    }
//    if (self.messages.count == 0) {
//        [self.messages addObject:message];
//        self.startTime = message.time;
//        self.endTime = message.time;
//        return YES;
//    }
//    if (message.time < self.endTime+FifteenMinute && message.time > self.startTime-FifteenMinute) {
//        NSInteger index = 0;
//        for (NSInteger i = self.messages.count-1; i >= 0; i--) {
//            WLIMMessage *msg = self.messages[i];
//            if (message.time > msg.time) {
//                index = i;
//                break;
//            }
//        }
//        if (index == self.messages.count-1) {
//            [self.messages addObject:message];
//            self.endTime = message.time;
//        } else if (index == 0) {
//            [self.messages insertObject:message atIndex:0];
//            self.startTime = message.time;
//        } else {
//            [self.messages insertObject:message atIndex:index+1];
//        }
//        return YES;
//    }
//    return NO;
//}

#pragma mark - new MessageGroup

- (void)refreshUser:(WLUser *)user
{
    NSArray *messages = [self.messageDic allValues];
    for (NSInteger i = 0; i < messages.count; i++) {
        WLIMMessage *message = messages[i];
        if ([message.senderUid isEqualToString:user.uid]) {
            message.senderNickName = user.nickName;
            message.senderHead = user.headUrl;
        }
    }
}

- (void)refreshAllSendingMessages
{
    NSArray *messages = [self.messageDic allValues];
    for (NSInteger i = 0; i < messages.count; i++) {
        WLIMMessage *message = messages[i];
        if (message.status == WLIMMessageStatusSending) {
            message.status = WLIMMessageStatusSendFailed;
        }
    }
}

- (void)refreshMessage:(WLIMMessage *)message
{
    WLIMMessage *msg = [self.messageDic objectForKey:message.messageId];
    msg.status = message.status;
}

- (NSUInteger)messagesCount
{
    return self.messages.count;
}

- (NSUInteger)indexOfMessage:(WLIMMessage *)message
{
    return [self.messages indexOfObject:message];
}

- (WLIMMessage *)messageAtIndex:(NSUInteger)index
{
    if (index < self.messages.count) {
        return [self.messages objectAtIndex:index];
    }
    return nil;
}

- (void)appendLastMessage:(WLIMMessage *)message
{
    if (self.messageDic == nil) {
        self.messageDic = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    [self.messageDic setObject:message forKey:message.messageId];
    [self.messages addObject:message];
    WLMessageGroup *group = [self.subGroups lastObject];
    if (message.time <= group.endTime+FifteenMinute) {
        group.endTime = message.time;
        group.range = NSMakeRange(group.range.location, group.range.length+1);
    } else {
        group = [[WLMessageGroup alloc] init];
        group.startTime = message.time;
        group.endTime = message.time;
        group.range = NSMakeRange(0, 1);
        [self.subGroups addObject:group];
    }
}

- (void)appendMessages:(NSArray<WLIMMessage *> *)messages
{
    if (self.messageDic == nil) {
        self.messageDic = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    for (NSInteger i = 0; i < messages.count; i++) {
        WLIMMessage *message = messages[i];
        [self.messageDic setObject:message forKey:message.messageId];
    }
}

- (NSArray<WLMessageGroup *> *)allMessageGroups
{
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:20];
    [self sortAllMessages];
    if (self.messages.count > 0) {
        WLIMMessage *message = self.messages[0];
        WLMessageGroup *group = [[WLMessageGroup alloc] init];
        group.startTime = message.time;
        group.endTime = message.time;
        group.range = NSMakeRange(0, 1);
        for (NSInteger i = 1; i < self.messages.count; i++) {
            WLIMMessage *message = self.messages[i];
            if (message.time <= group.endTime+FifteenMinute) {
                group.endTime = message.time;
                group.range = NSMakeRange(group.range.location, group.range.length+1);
            } else {
                [groups addObject:group];
                group = [[WLMessageGroup alloc] init];
                group.startTime = message.time;
                group.endTime = message.time;
                group.range = NSMakeRange(i, 1);
            }
        }
        [groups addObject:group];
    }
    for (NSInteger i = 0; i < groups.count; i++) {
        WLMessageGroup *group = groups[i];
        NSArray *subMessages = [self.messages subarrayWithRange:group.range];
        group.messages = [NSMutableArray arrayWithArray:subMessages];
    }
    self.subGroups = groups;
    return self.subGroups;
}

- (NSArray<WLIMMessage *> *)sortAllMessages
{
    NSArray *allMessages = [self sortMessages:[self.messageDic allValues]];
    self.messages = [NSMutableArray arrayWithArray:allMessages];
    return self.messages;
}

- (NSArray<WLIMMessage *> *)sortMessages:(NSArray<WLIMMessage *> *)messages
{
    return [messages sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
            {
                WLIMMessage *message1 = obj1;
                WLIMMessage *message2 = obj2;
                if (message1.time > message2.time)
                {
                    return NSOrderedDescending;
                }
                else if (message1.time < message2.time)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedSame;
                }
            }];
}
                                 
@end
