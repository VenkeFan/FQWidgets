//
//  WLFeedRepostCell.m
//  welike
//
//  Created by fan qi on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedRepostCell.h"
#import "UIImageView+Extension.h"
#import "WLHeadView.h"
#import "TYLabel.h"
#import "WLTextPost.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLLinkPost.h"
#import "WLForwardPost.h"
#import "WLHandledFeedModel.h"
#import "WLRichItem.h"
#import "WLWebViewController.h"

@interface WLFeedRepostCell () <TYLabelDelegate>

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) CATextLayer *nameLayer;
@property (nonatomic, strong) TYLabel *feedLabel;
@property (nonatomic, strong) CATextLayer *timeLayer;
@property (nonatomic, strong) CALayer *lineLayer;

@end

@implementation WLFeedRepostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
    _avatarView.userInteractionEnabled = NO;
    _avatarView.backgroundColor = [UIColor whiteColor];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_avatarView];
    
    _nameLayer = [self textLayerWithFont:reCellNameFont textColor:kDateTimeFontColor];
    [self.contentView.layer addSublayer:_nameLayer];
    
    _feedLabel = [[TYLabel alloc] init];
    _feedLabel.delegate = self;
    _feedLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_feedLabel];
    
    _timeLayer = [self textLayerWithFont:reCellDateTimeFont textColor:kDateTimeFontColor];
    [self.contentView.layer addSublayer:_timeLayer];
    
    _lineLayer = [CALayer layer];
    _lineLayer.backgroundColor = kSeparateLineColor.CGColor;
    [self.contentView.layer addSublayer:_lineLayer];
}

- (CATextLayer *)textLayerWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.contentsScale = kScreenScale;
    txtLayer.alignmentMode = kCAAlignmentJustified;
    txtLayer.truncationMode = kCATruncationEnd;
    txtLayer.foregroundColor = textColor.CGColor;
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    txtLayer.font = fontRef;
    txtLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    return txtLayer;
}

#pragma mark - Public

- (void)setLayout:(WLFeedRepostLayout *)layout {
    _layout = layout;
    
    _avatarView.frame = layout.avatarFrame;
    _avatarView.feedModel = layout.feedModel;
    
    _nameLayer.frame = layout.nameFrame;
    _nameLayer.string = layout.feedModel.nickName;
    
    _feedLabel.frame = layout.textFrame;
    [_feedLabel setTextRender:layout.handledFeedModel.textRender];
    
    _timeLayer.frame = layout.timeFrame;
    _timeLayer.string = layout.souceTail;
    
    _lineLayer.frame = layout.lineFrame;
}

#pragma mark - TYLabelDelegate

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight {
    NSString *key = textHighlight.userInfo.allKeys.firstObject;
    if ([key isEqualToString:WLRICH_TYPE_MENTION]) {
        if ([self.delegate respondsToSelector:@selector(feedRepostCell:didClickedUser:)]) {
            [self.delegate feedRepostCell:self didClickedUser:textHighlight.userInfo[key]];
        }
    } else if ([key isEqualToString:WLRICH_TYPE_TOPIC]) {
        if ([self.delegate respondsToSelector:@selector(feedRepostCell:didClickedTopic:)]) {
            [self.delegate feedRepostCell:self didClickedTopic:textHighlight.userInfo[key]];
        }
    } else if ([key isEqualToString:WLRICH_TYPE_LINK]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:textHighlight.userInfo[key]]];
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:textHighlight.userInfo[key]];
        [[AppContext rootViewController] pushViewController:webViewController animated:YES];
    } else if ([key isEqualToString:WLRICH_TYPE_MORE]) {
        if ([self.delegate respondsToSelector:@selector(feedRepostCell:didClickedFeed:)]) {
            [self.delegate feedRepostCell:self didClickedFeed:_layout];
        }
    }
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_avatarView.frame, point) || CGRectContainsPoint(_nameLayer.frame, point)) {
        if ([self.delegate respondsToSelector:@selector(feedRepostCell:didClickedUser:)]) {
            [self.delegate feedRepostCell:self didClickedUser:_layout.feedModel.uid];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(feedRepostCell:didClickedFeed:)]) {
            [self.delegate feedRepostCell:self didClickedFeed:_layout];
        }
    }
}

@end
