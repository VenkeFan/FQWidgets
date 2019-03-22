//
//  WLFeedArticleView.m
//  welike
//
//  Created by fan qi on 2019/2/15.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLFeedArticleView.h"
#import "WLArticalPostModel.h"
#import "WLArticalController.h"

@interface WLFeedArticleView ()

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) CALayer *shadowLayer;
@property (nonatomic, strong) CAGradientLayer *topGradientLayer;
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *articleIcon;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation WLFeedArticleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kLightBackgroundViewColor;
        
        _coverView = [[UIImageView alloc] init];
        _coverView.image = [AppContext getImageForKey:@"long_text_default"];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
        [self addSubview:_coverView];
        
        _shadowLayer = [CALayer layer];
        _shadowLayer.hidden = NO;
        _shadowLayer.backgroundColor = kUIColorFromRGBA(0x000000, 0.2).CGColor;
        [self.layer addSublayer:_shadowLayer];
        
        _topGradientLayer = [CAGradientLayer layer];
        _topGradientLayer.hidden = YES;
        _topGradientLayer.colors = @[(__bridge id)kUIColorFromRGBA(0x000000, 0.3).CGColor, (__bridge id)kUIColorFromRGBA(0x000000, 0.0).CGColor];
        _topGradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _topGradientLayer.endPoint = CGPointMake(0.5, 1.0);
        [self.layer addSublayer:_topGradientLayer];
        
        _bottomGradientLayer = [CAGradientLayer layer];
        _bottomGradientLayer.hidden = YES;
        _bottomGradientLayer.colors = @[(__bridge id)kUIColorFromRGBA(0x000000, 0.3).CGColor, (__bridge id)kUIColorFromRGBA(0x000000, 0.0).CGColor];
        _bottomGradientLayer.startPoint = CGPointMake(0.5, 1.0);
        _bottomGradientLayer.endPoint = CGPointMake(0.5, 0.0);
        [self.layer addSublayer:_bottomGradientLayer];
        
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        _avatarView.backgroundColor = kLightBackgroundViewColor;
        _avatarView.layer.cornerRadius = CGRectGetWidth(_avatarView.bounds) * 0.5;
        _avatarView.layer.masksToBounds = YES;
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = kRegularFont(kLightFontSize);
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_nameLabel];
        
        _articleIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        _articleIcon.enabled = NO;
        [_articleIcon setImage:[AppContext getImageForKey:@"feed_article"] forState:UIControlStateDisabled];
        [_articleIcon setTitle:[AppContext getStringForKey:@"article" fileName:@"feed"]
                      forState:UIControlStateDisabled];
        [_articleIcon setTitleEdgeInsets:UIEdgeInsetsMake(0, 4.0, 0, 0)];
        [_articleIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _articleIcon.titleLabel.font = kRegularFont(10.0);
        [_articleIcon sizeToFit];
        _articleIcon.width += _articleIcon.titleEdgeInsets.left;
        [self addSubview:_articleIcon];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kRegularFont(kNameFontSize);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = 12, y = 12;
    CGFloat width = CGRectGetWidth(self.frame), height = CGRectGetHeight(self.frame);
    CGFloat gradientHeight = 75;
    
    _coverView.frame = self.bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _shadowLayer.frame = self.bounds;
    _topGradientLayer.frame = CGRectMake(0, 0, width, gradientHeight);
    _bottomGradientLayer.frame = CGRectMake(0, height - gradientHeight, width, gradientHeight);
    [CATransaction commit];
    
    CGRect frame = _avatarView.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    _avatarView.frame = frame;
    
    _articleIcon.center = CGPointMake(width - x - CGRectGetWidth(_articleIcon.frame) * 0.5,
                                      CGRectGetMidY(_avatarView.frame));
    
    _titleLabel.frame = CGRectMake(0, 0, width - x * 2, 42);
    _titleLabel.center = CGPointMake(width * 0.5, height - y - CGRectGetHeight(_titleLabel.frame) * 0.5);
    
    CGFloat padding = 4.0;
    _nameLabel.frame = CGRectMake(x + CGRectGetWidth(_avatarView.frame) + padding, 0, width - x * 2 - CGRectGetWidth(_avatarView.frame) - CGRectGetWidth(_articleIcon.frame) - padding * 2 , 16);
    _nameLabel.centerY = CGRectGetMidY(_avatarView.frame);
}

- (void)setArticleModel:(WLArticalPostModel *)articleModel {
    _articleModel = articleModel;
    
    if (articleModel.cover) {
        _shadowLayer.hidden = YES;
        [_coverView fq_setImageWithURLString:articleModel.cover];
    } else {
        _shadowLayer.hidden = NO;
        _coverView.image = [AppContext getImageForKey:@"long_text_default"];
    }
    _topGradientLayer.hidden = _bottomGradientLayer.hidden = !_shadowLayer.hidden;
    
    [_avatarView fq_setImageWithURLString:articleModel.userInfo.headUrl placeholder:[UIImage new]];
    
    _nameLabel.text = articleModel.userInfo.nickName;
    
    _titleLabel.text = articleModel.title;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    WLArticalController *ctr = [[WLArticalController alloc] initWithOriginalFeedLayout:_articleModel];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

@end
