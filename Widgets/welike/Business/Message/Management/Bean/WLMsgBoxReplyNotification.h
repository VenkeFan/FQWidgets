//
//  WLMsgBoxReplyNotification.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMsgBoxNotificationBase.h"
#import "WLPostBase.h"
#import "WLComment.h"

@interface WLMsgBoxReplyNotification : WLMsgBoxNotificationBase

@property (nonatomic, strong) WLComment *reply;

@end