//
//  WLIMMessage+MessageCell.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMMessage.h"

#import "WLMessageTableViewCell.h"

@interface WLIMMessage (MessageCell)

+ (Class)messageCellClass;

+ (instancetype)messageCellInTableView:(UITableView *)tableView;

- (CGFloat)messageCellHeightInTableView:(UITableView *)tableView;

@end
