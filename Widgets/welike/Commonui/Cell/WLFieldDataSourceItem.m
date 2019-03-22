//
//  WLFieldDataSourceItem.m
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFieldDataSourceItem.h"

#define kFieldHeight        37.f

@interface WLFieldDataSourceItem ()

@property (nonatomic, assign) CGFloat cellHeight;

@end

@implementation WLFieldDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cellHeight = kFieldHeight;
        self.editingKeyboardType = UIKeyboardTypeDefault;
        self.secureTextEntry = NO;
    }
    return self;
}

- (CGFloat)calculateCellHeight
{
    return _cellHeight;
}

@end
