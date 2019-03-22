//
//  WLNormalHisDataSourceItem.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNormalHisDataSourceItem.h"

#define kSearchSugCellHeight             36.f

@implementation WLNormalHisDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isTail = YES;
        _cellHeight = kSearchSugCellHeight;
    }
    return self;
}

@end
