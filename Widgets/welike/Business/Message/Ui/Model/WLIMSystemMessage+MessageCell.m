//
//  WLIMSystemMessage+MessageCell.m
//  welike
//
//  Created by luxing on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMSystemMessage+MessageCell.h"

@implementation WLIMSystemMessage (MessageCell)


+ (Class)messageCellClass
{
    return [WLSystemMessageTableViewCell class];
}

- (CGFloat)messageCellHeightInTableView:(UITableView *)tableView
{
    CGFloat height = kMessageCellTopMargin;
    CGSize contentSize = [self.text boundingRectWithSize:CGSizeMake(kTextMessageCellTextMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNoticeMessageCellFontSize]} context:nil].size;
    CGFloat textHeight = MAX(kTextMessageCellTextMinHeight, contentSize.height);
    height+=textHeight;
    return height;
}

@end
