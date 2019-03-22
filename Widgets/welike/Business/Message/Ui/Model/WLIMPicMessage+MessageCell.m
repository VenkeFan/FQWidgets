//
//  WLIMPicMessage+MessageCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMPicMessage+MessageCell.h"
#import "WLAccountManager.h"

@implementation WLIMPicMessage (MessageCell)

+ (Class)messageCellClass
{
    return [WLPicMessageTableViewCell class];
}

- (CGFloat)messageCellHeightInTableView:(UITableView *)tableView
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    CGFloat height = kMessageCellTopMargin+kPicMessageCellHeight;
    if ([self.senderUid isEqualToString:account.uid] == NO && (self.sessionType == WLIMSessionTypeGroup || self.sessionType ==  WLIMSessionTypeStranger)) {
        height += (kMessageCellNameLablePading+kMessageCellNameLableHeight);
    }
    return height;
}

@end
