//
//  WLIMMessage+MessageCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMMessage+MessageCell.h"

@implementation WLIMMessage (MessageCell)

+ (Class)messageCellClass
{
    return [WLMessageTableViewCell class];
}

+ (instancetype)messageCellInTableView:(UITableView *)tableView
{
    return [[self messageCellClass] reusableCellOfTableView:tableView];
}

- (CGFloat)messageCellHeightInTableView:(UITableView *)tableView
{
    return 0;
}

@end
