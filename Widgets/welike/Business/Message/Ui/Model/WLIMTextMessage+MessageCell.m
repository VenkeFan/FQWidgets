//
//  WLIMTextMessage+MessageCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMTextMessage+MessageCell.h"
#import "WLPicMessageTableViewCell.h"
#import "WLAccountManager.h"
#import "TYTextRender.h"

@implementation WLIMTextMessage (MessageCell)

+ (Class)messageCellClass
{
    return [WLTextMessageTableViewCell class];
}

- (WLImTextModel *)textRichModel
{
    WLImTextModel *richModel = [[WLImTextModel alloc] init];
    richModel.font = [UIFont systemFontOfSize:kNameFontSize];
    richModel.renderWidth = kTextMessageCellTextMaxWidth;
    richModel.lineBreakMode = NSLineBreakByCharWrapping;
    [richModel handleRichModel:self.text];
    return richModel;
}

- (CGFloat)messageCellHeightInTableView:(UITableView *)tableView
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    CGFloat height = kMessageCellTopMargin+2*kTextMessageCellTextTopPading;
//    CGSize contentSize = [self.text boundingRectWithSize:CGSizeMake(kTextMessageCellTextMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNameFontSize]}
//                                                 context:nil].size;
    CGFloat textH = [self textRichModel].richTextHeight;
    CGFloat textHeight = MAX(kTextMessageCellTextMinHeight, textH);
    height += textHeight;
    if ([self.senderUid isEqualToString:account.uid] == NO && (self.sessionType == WLIMSessionTypeGroup || self.sessionType ==  WLIMSessionTypeStranger)) {
        height += (kMessageCellNameLablePading+kMessageCellNameLableHeight);
    }
    return height;
}

@end
