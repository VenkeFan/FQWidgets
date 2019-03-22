//
//  WLMsgBoxMentionNotification.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMsgBoxNotificationBase.h"
#import "WLComment.h"

typedef NS_ENUM(NSInteger, WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE)
{
    WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_POST = 1,
    WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_COMMENT,
    WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_REPLY
};

@interface WLMsgBoxMentionNotification : WLMsgBoxNotificationBase

@property (nonatomic, assign) WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE parentType;
@property (nonatomic, strong) WLComment *comment;
@property (nonatomic, strong) WLComment *reply;

@end
