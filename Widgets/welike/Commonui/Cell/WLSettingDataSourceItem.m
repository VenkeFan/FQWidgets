//
//  WLSettingDataSourceItem.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSettingDataSourceItem.h"

@implementation WLSettingDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _badgeNum = 0;
        _enableNavMark = YES;
        _isTail = YES;
        _cellHeight = kSettingCellHeight;
    }
    return self;
}

@end
