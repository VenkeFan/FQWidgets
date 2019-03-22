//
//  WLMsgBoxNotificationBase.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPostBase.h"

#define MSG_BOX_MENTION_FORWARD_ACTION                @"FORWARD"
#define MSG_BOX_MENTION_POST_ACTION                   @"POST_MENTION"
#define MSG_BOX_MENTION_COMMENT_ACTION                @"COMMENT_MENTION"
#define MSG_BOX_MENTION_REPLY_ACTION                  @"REPLY_MENTION"
#define MSG_BOX_COMMENT_COMMENT_ACTION                @"COMMENT"
#define MSG_BOX_COMMENT_REPLY_ACTION                  @"REPLY"
#define MSG_BOX_LIKE_POST_ACTION                      @"POST_LIKE"
#define MSG_BOX_LIKE_COMMENT_ACTION                   @"COMMENT_LIKE"
#define MSG_BOX_LIKE_REPLY_ACTION                     @"REPLY_LIKE"

@interface WLMsgBoxNotificationBase : NSObject

@property (nonatomic, copy) NSString *nid;
@property (nonatomic, assign) long long time;
@property (nonatomic, copy) NSString *sourceUid;
@property (nonatomic, copy) NSString *sourceNickName;
@property (nonatomic, copy) NSString *sourceHead;
@property (nonatomic, assign) NSInteger vip;
@property (nonatomic, strong) WLPostBase *parentPost;

+ (WLMsgBoxNotificationBase *)parseFromNetworkJSON:(NSDictionary *)json;

@end
