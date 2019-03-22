//
//  WLIMMessage.m
//  IMTest
//
//  Created by luxing on 2018/5/5.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import "WLIMMessage.h"
#import "WLIMTextMessage.h"
#import "WLIMPicMessage.h"
#import "WLIMSystemMessage.h"
#import "WLIMSession.h"
#import "BibiProtoApplication.pbobjc.h"
#import "FMDB.h"
#import "WLIMDBDefines.h"

@implementation WLIMMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return self;
}

- (WLIMMessage *)copy
{
    WLIMMessage *message = nil;
    if (message.type == WLIMMessageTypeTxt)
    {
        WLIMTextMessage *textMessage = [[WLIMTextMessage alloc] init];
        textMessage.text = ((WLIMTextMessage *)self).text;
        message = textMessage;
    }
    else if (message.type == WLIMMessageTypePic)
    {
        WLIMPicMessage *picMessage = [[WLIMPicMessage alloc] init];
        picMessage.picUri = ((WLIMPicMessage *)self).picUri;
        picMessage.localFileName = ((WLIMPicMessage *)self).localFileName;
        message = picMessage;
    }
    if (message != nil)
    {
        message.messageId = self.messageId;
        message.sessionId = self.sessionId;
        message.sessionName = self.sessionName;
        message.sessionHead = self.sessionHead;
        message.sessionType = self.sessionType;
        message.sessionEnableChat = self.sessionEnableChat;
        message.sessionVisableChat = self.sessionVisableChat;
        message.senderUid = self.senderUid;
        message.senderNickName = self.senderNickName;
        message.senderHead = self.senderHead;
        message.status = self.status;
        message.time = self.time;
    }
    return message;
}

- (MessageHeader *)messageHeader
{
    MessageHeader *header = [[MessageHeader alloc] init];
    header.messageId = self.messageId;
    header.classified = MessageClassified_P2P;
    header.fromUid = self.senderUid;
    header.remoteUid = self.remoteUid;
    if (self.senderNickName == nil)
    {
        header.groupName = @"";
        header.senderName = @"";
    }
    else
    {
        header.groupName = self.senderNickName;
        header.senderName = self.senderNickName;
    }
    header.createtime = self.time;
    if (self.type == WLIMMessageTypeTxt)
    {
        header.type = MessageHeader_MessageType_Text;
    }
    else if (self.type == WLIMMessageTypePic)
    {
        header.type = MessageHeader_MessageType_Pic;
    }
    header.persistent = YES;
    if ([self.from length] > 0)
    {
        if (header.propertiesArray == nil)
        {
            header.propertiesArray = [NSMutableArray array];
        }
        MessageHeader_Property *property = [[MessageHeader_Property alloc] init];
        property.key = @"noticeType";
        property.value = self.from;
        [header.propertiesArray addObject:property];
    }
    if ([self.sessionHead length] > 0 && [self.senderHead length] > 0)
    {
        header.groupURL = self.senderHead;
        header.senderURL = self.senderHead;
    }
    return header;
}

- (void)parseMessageHeader:(MessageHeader *)messageHeader
{
    self.messageId = messageHeader.messageId;
    self.sessionId = [WLIMSession buildSessionIdWithUid1:messageHeader.fromUid uid2:messageHeader.remoteUid];
    self.sessionName = messageHeader.groupName;
    self.sessionHead = [messageHeader.groupURL convertToHttps];
    if (messageHeader.classified == MessageClassified_P2P)
    {
        self.sessionType = WLIMSessionTypeP2P;
    }
    else
    {
        self.sessionType = WLIMSessionTypeUnknown;
    }
    self.sessionEnableChat = messageHeader.enableChat;
    self.sessionVisableChat = messageHeader.visableChat;
    self.senderUid = messageHeader.fromUid;
    self.senderNickName = messageHeader.senderName;
    self.senderHead = [messageHeader.senderURL convertToHttps];
    self.remoteUid = messageHeader.remoteUid;
    self.time = messageHeader.createtime;
    self.isGreet = messageHeader.isGreet;
}

#pragma mark - WLIMPacking
- (NSData *)packetBody
{
    return nil;
}

#pragma mark - WLIMDBModeling
+ (WLIMMessage *)decodeFromDBSet:(FMResultSet *)resultSet
{
    WLIMMessageType type = [resultSet intForColumn:IM_MESSAGE_COL_TYPE];
    
    WLIMMessage *message = nil;
    if (type == WLIMMessageTypeTxt)
    {
        WLIMTextMessage *textMessage = [[WLIMTextMessage alloc] init];
        textMessage.text = [resultSet stringForColumn:IM_MESSAGE_COL_TEXT];
        message = textMessage;
    }
    else if (type == WLIMMessageTypePic)
    {
        WLIMPicMessage *picMessage = [[WLIMPicMessage alloc] init];
        picMessage.picUri = [resultSet stringForColumn:IM_MESSAGE_COL_PIC];
        picMessage.localFileName = [resultSet stringForColumn:IM_MESSAGE_COL_FILE_NAME];
        message = picMessage;
    }
    else if (type == WLIMMessageTypeSystem)
    {
        WLIMSystemMessage *sysMessage = [[WLIMSystemMessage alloc] init];
        sysMessage.text = [resultSet stringForColumn:IM_MESSAGE_COL_TEXT];
        message = sysMessage;
    }
    if (message != nil)
    {
        message.messageId = [resultSet stringForColumn:IM_MESSAGE_COL_MID];
        message.sessionId = [resultSet stringForColumn:IM_MESSAGE_COL_SID];
        message.sessionName = [resultSet stringForColumn:IM_MESSAGE_COL_SESSION_NAME];
        message.sessionHead = [resultSet stringForColumn:IM_MESSAGE_COL_SESSION_HEAD];
        message.sessionType = [resultSet intForColumn:IM_MESSAGE_COL_SESSION_TYPE];
        message.sessionEnableChat = NO;
        message.sessionVisableChat = NO;
        message.senderUid = [resultSet stringForColumn:IM_MESSAGE_COL_SENDER_UID];
        message.senderNickName = [resultSet stringForColumn:IM_MESSAGE_COL_SENDER_NAME];
        message.senderHead = [resultSet stringForColumn:IM_MESSAGE_COL_SENDER_HEAD];
        message.status = [resultSet intForColumn:IM_MESSAGE_COL_STATUS];
        message.time = [resultSet longLongIntForColumn:IM_MESSAGE_COL_TIME];
    }
    return message;
}

- (NSMutableDictionary *)encodeToDBModel
{
    NSMutableDictionary *model = [NSMutableDictionary dictionaryWithCapacity:18];
    
    if (self.type == WLIMMessageTypeTxt)
    {
        NSString *text = ((WLIMTextMessage *)self).text;
        if ([text length] > 0)
        {
            [model setObject:text forKey:IM_MESSAGE_COL_TEXT];
        }
    }
    else if (self.type == WLIMMessageTypePic)
    {
        NSString *picUri = ((WLIMPicMessage *)self).picUri;
        NSString *localFileName = ((WLIMPicMessage *)self).localFileName;
        if ([picUri length] > 0)
        {
            [model setObject:picUri forKey:IM_MESSAGE_COL_PIC];
        }
        if ([localFileName length] > 0)
        {
            [model setObject:localFileName forKey:IM_MESSAGE_COL_FILE_NAME];
        }
    }
    else if (self.type == WLIMMessageTypeSystem)
    {
        NSString *text = ((WLIMTextMessage *)self).text;
        if ([text length] > 0)
        {
            [model setObject:text forKey:IM_MESSAGE_COL_TEXT];
        }
    }
    
    [model setObject:self.messageId forKey:IM_MESSAGE_COL_MID];
    [model setObject:self.sessionId forKey:IM_MESSAGE_COL_SID];
    if ([self.sessionName length] > 0)
    {
        [model setObject:self.sessionName forKey:IM_MESSAGE_COL_SESSION_NAME];
    }
    else
    {
        [model setObject:@"" forKey:IM_MESSAGE_COL_SESSION_NAME];
    }
    if ([self.sessionHead length] > 0)
    {
        [model setObject:self.sessionHead forKey:IM_MESSAGE_COL_SESSION_HEAD];
    }
    [model setObject:[NSNumber numberWithInteger:self.sessionType] forKey:IM_MESSAGE_COL_SESSION_TYPE];
    [model setObject:self.senderUid forKey:IM_MESSAGE_COL_SENDER_UID];
    if ([self.senderNickName length] > 0)
    {
        [model setObject:self.senderNickName forKey:IM_MESSAGE_COL_SENDER_NAME];
    }
    else
    {
        [model setObject:@"" forKey:IM_MESSAGE_COL_SENDER_NAME];
    }
    if ([self.senderHead length] > 0)
    {
        [model setObject:self.senderHead forKey:IM_MESSAGE_COL_SENDER_HEAD];
    }
    
    if (self.status == WLIMMessageStatusSending)
    {
        [model setObject:@(WLIMMessageStatusSendFailed) forKey:IM_MESSAGE_COL_STATUS];
    } else {
        [model setObject:[NSNumber numberWithInteger:self.status] forKey:IM_MESSAGE_COL_STATUS];
    }
    [model setObject:[NSNumber numberWithLongLong:self.time] forKey:IM_MESSAGE_COL_TIME];
    [model setObject:[NSNumber numberWithInteger:self.type] forKey:IM_MESSAGE_COL_TYPE];
    
    return model;
}

- (BOOL)isEqual:(id)object
{
    WLIMMessage *message = object;
    if ([self.messageId integerValue] == [message.messageId integerValue]) {
        return YES;
    }
    return NO;
}

@end
