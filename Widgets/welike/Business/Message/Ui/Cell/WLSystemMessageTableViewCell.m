//
//  WLSystemMessageTableViewCell.m
//  welike
//
//  Created by luxing on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSystemMessageTableViewCell.h"

@interface WLSystemMessageTableViewCell ()

@property(nonatomic, strong) UILabel *contentLabel;

@end

@implementation WLSystemMessageTableViewCell

- (void)initMessageCell
{
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.textColor = kLightLightFontColor;
    _contentLabel.font = [UIFont systemFontOfSize:kNoticeMessageCellFontSize];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_contentLabel];
}

- (void)bindMessage:(WLIMMessage *)message
{
    WLIMSystemMessage *systemMessage = (WLIMSystemMessage *)message;
    self.message = message;
    self.contentLabel.text = systemMessage.text;
}

- (void)layoutMessageCell
{
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth, CGFLOAT_MAX)];
    CGFloat textMaxWidth = MIN(size.width,kTextMessageCellTextMaxWidth);
    self.contentLabel.frame = CGRectMake((CGRectGetWidth(self.frame)-textMaxWidth)/2, kMessageCellTopMargin,textMaxWidth, CGRectGetHeight(self.frame)-kMessageCellTopMargin);
}

- (CGSize)bubbleSize
{
    return CGSizeZero;
}

@end
