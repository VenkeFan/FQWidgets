//
//  WLNormalHisDataSourceItem.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLSugResult.h"

typedef NS_ENUM(NSInteger, WELIKE_NORMAL_HISTORY_ACTION_TYPE)
{
    WELIKE_NORMAL_HISTORY_ACTION_TYPE_DEL = 1,
    WELIKE_NORMAL_HISTORY_ACTION_TYPE_NAV
};

@interface WLNormalHisDataSourceItem : NSObject

@property (nonatomic, strong) WLSugResult *sug;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, assign) WELIKE_NORMAL_HISTORY_ACTION_TYPE actionType;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, assign) BOOL isTail;

@end
