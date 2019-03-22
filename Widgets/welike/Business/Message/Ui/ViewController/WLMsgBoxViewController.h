//
//  WLMsgBoxViewController.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTableViewController.h"

typedef NS_ENUM(NSInteger, WELIKE_MSG_BOX_TYPE)
{
    WELIKE_MSG_BOX_TYPE_MENTION = 1,
    WELIKE_MSG_BOX_TYPE_COMMENT,
    WELIKE_MSG_BOX_TYPE_LIKE
};

@interface WLMsgBoxViewController : WLTableViewController

@property (nonatomic, assign) WELIKE_MSG_BOX_TYPE type;

@end
