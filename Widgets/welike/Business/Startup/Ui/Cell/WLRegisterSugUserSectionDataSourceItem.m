//
//  WLRegisterSugUserSectionDataSourceItem.m
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterSugUserSectionDataSourceItem.h"
#import "WLRegisterSugUserDataSourceItem.h"

#define kRegisterSugUserSectionCellHeight       57.f

@implementation WLRegisterSugUserSectionDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _height = kRegisterSugUserSectionCellHeight;
    }
    return self;
}

- (NSInteger)selectedUsersCount
{
    NSInteger count = 0;
    if ([self.users count] > 0)
    {
        for (NSInteger i = 0; i < [self.users count]; i++)
        {
            WLRegisterSugUserDataSourceItem *item = [self.users objectAtIndex:i];
            if (item.isSelected == YES)
            {
                count++;
            }
        }
    }
    return count;
}

- (void)selectAll:(BOOL)selected
{
    if ([self.users count] > 0)
    {
        for (NSInteger i = 0; i < [self.users count]; i++)
        {
            WLRegisterSugUserDataSourceItem *item = [self.users objectAtIndex:i];
            item.isSelected = selected;
        }
    }
}

@end
