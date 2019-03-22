//
//  WLFeedLikeUserCell.m
//  welike
//
//  Created by fan qi on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedLikeUserCell.h"
#import "WLUser.h"
#import "WLHeadView.h"
#import "WLSingleContentManager.h"

#define cellX           16

@interface WLFeedLikeUserCell ()

@property (nonatomic, strong) CALayer *likeLayer;
@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) CALayer *followLayer;
@property (nonatomic, strong) CALayer *separateLayer;

@end

@implementation WLFeedLikeUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _likeLayer = [CALayer layer];
        UIImage *likeImg = [AppContext getImageForKey:@"feed_like_normal"];
        _likeLayer.frame = CGRectMake(0, 0, likeImg.size.width, likeImg.size.height);
        _likeLayer.contents = (__bridge id)likeImg.CGImage;
        _likeLayer.contentsGravity = kCAGravityResizeAspect;
        [self.contentView.layer addSublayer:_likeLayer];
        
        _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarView.frame = CGRectMake(0, 0, kAvatarSizeSmall, kAvatarSizeSmall);
        _avatarView.userInteractionEnabled = NO;
        [self.contentView addSubview:_avatarView];
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = kNameFontColor;
        _nameLab.font = kRegularFont(kMediumNameFontSize);
        [self.contentView addSubview:_nameLab];
        
        UIImage *arrowImg = [AppContext getImageForKey:@"common_arrow_right_orange"];
        _followLayer = [CALayer layer];
        _followLayer.frame = CGRectMake(0, 0, arrowImg.size.width, arrowImg.size.height);
        _followLayer.contents = (__bridge id)arrowImg.CGImage;
        _followLayer.contentsGravity = kCAGravityResizeAspect;
        [self.contentView.layer addSublayer:_followLayer];
        
        _separateLayer = [CALayer layer];
        _separateLayer.backgroundColor = kSeparateLineColor.CGColor;
        [self.contentView.layer addSublayer:_separateLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat centerY = CGRectGetHeight(self.bounds) * 0.5;
    
    _likeLayer.position = CGPointMake(cellX + CGRectGetWidth(_likeLayer.bounds) * 0.5, centerY);
    
    _avatarView.center = CGPointMake(CGRectGetMaxX(_likeLayer.frame) + cellX + CGRectGetWidth(_avatarView.bounds) * 0.5, centerY);
    _nameLab.center = CGPointMake(CGRectGetMaxX(_avatarView.frame) + 9 + CGRectGetWidth(_nameLab.bounds) * 0.5, centerY);
    
    _followLayer.position = CGPointMake(CGRectGetWidth(self.bounds) - cellX - CGRectGetWidth(_followLayer.bounds) * 0.5, centerY);
    
    _separateLayer.frame = CGRectMake(CGRectGetMinX(_avatarView.frame), CGRectGetHeight(self.bounds) - 1.0, CGRectGetWidth(self.bounds) - CGRectGetMinX(_avatarView.frame), 1.0);
}

- (void)setItemModel:(WLUser *)itemModel {
    [_avatarView setUser:itemModel];
    UIImage *likeImg = [WLSingleContentManager superLikeImageWithExp:itemModel.superLikeExp];
    _likeLayer.contents = (__bridge id)likeImg.CGImage;
    _nameLab.text = itemModel.nickName;
    [_nameLab sizeToFit];
}

@end
