//
//  WLRegisterSugUserDataSourceItem.m
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterSugUserDataSourceItem.h"

#define kRegisterSugUserCellHeight     65.f

@implementation WLRegisterSugUserDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isSelected = YES;
        _height = kRegisterSugUserCellHeight;
    }
    return self;
}

@end
