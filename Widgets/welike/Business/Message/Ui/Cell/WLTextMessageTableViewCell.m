//
//  WLTextMessageTableViewCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTextMessageTableViewCell.h"
#import "TYLabel.h"

@interface WLTextMessageTableViewCell () <TYLabelDelegate>

@property(nonatomic, strong) TYLabel *contentLabel;

@end

@implementation WLTextMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {        
        _contentLabel = [[TYLabel alloc] init];
        _contentLabel.delegate = self;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = kNameFontColor;
        _contentLabel.font = [UIFont systemFontOfSize:kNameFontSize];
        _contentLabel.numberOfLines = 0;
        [self.bubbleImageView addSubview:_contentLabel];
    }
    return self;
}

- (void)addGestureRecognizerForBubbleView
{
}

- (void)bindOtherView
{
    WLIMTextMessage *textMessage = (WLIMTextMessage *)self.message;
    WLImTextModel *textModel = [textMessage textRichModel];
     [self.contentLabel setTextRender:textModel.textRender];
    self.contentLabel.width = textModel.textRender.textBound.size.width;
}

- (void)layoutOtherView
{
    self.contentLabel.frame = CGRectMake(kTextMessageCellTextLeftPading, kTextMessageCellTextTopPading, CGRectGetWidth(self.bubbleImageView.frame)-2*kTextMessageCellTextLeftPading, CGRectGetHeight(self.bubbleImageView.frame)-2*kTextMessageCellTextTopPading);
}

- (CGSize)bubbleSize
{
    CGSize size = [super bubbleSize];
   // CGSize textSize =  [self.contentLabel sizeThatFits:CGSizeMake(size.width, size.height)];
    return CGSizeMake(MIN(size.width,ceil(_contentLabel.width+2*kTextMessageCellTextLeftPading)),size.height);
}

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight
{
    NSString *url = textHighlight.userInfo[@"LINK"];
    if (url != nil && self.delegate && [self.delegate respondsToSelector:@selector(message:didTouchLinkUrl:)]) {
        [self.delegate message:self.message didTouchLinkUrl:url];
    }
}

- (void)label:(TYLabel *)label didLongPressedTextHighlight:(TYTextHighlight *)textHighlight
{
    
}

@end
