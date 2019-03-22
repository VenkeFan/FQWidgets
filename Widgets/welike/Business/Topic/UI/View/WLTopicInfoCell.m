//
//  WLTopicInfoCell.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicInfoCell.h"
#import "UIImageView+Extension.h"
#import "WLTopicInfoModel.h"
#import "WLUser.h"
#import "WLHeadView.h"

#define marginX                             12
#define marginY                             15
#define defaultDisplayUsersCount            6

@interface WLTopicInfoCell ()

@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) CALayer *shadeLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CATextLayer *userCountLayer;

@property (nonatomic, strong) UIView *usersView;

@end

@implementation WLTopicInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    [self.contentView addSubview:self.bgImgView];
    [self.contentView.layer addSublayer:self.shadeLayer];
    [self.contentView.layer addSublayer:self.titleLayer];
    [self.contentView.layer addSublayer:self.userCountLayer];
    [self.contentView addSubview:self.usersView];
}

#pragma mark - Public

- (void)setItemModel:(WLTopicInfoModel *)itemModel {
    _itemModel = itemModel;
    
    [self.bgImgView fq_setImageWithURLString:itemModel.bannerUrl placeholder:[AppContext getImageForKey:@"topic_bg"]];
    
    self.titleLayer.string = itemModel.topicName;
    self.userCountLayer.string = [NSString stringWithFormat:@"%ld %@", (long)itemModel.postsCount, [AppContext getStringForKey:@"mine_post_num_text" fileName:@"user"]];
}

- (void)setUserArray:(NSArray *)userArray {
    if (userArray.count == 0 || [_userArray isEqual:userArray]) {
        return;
    }
    
    _userArray = userArray;
    
    [self.usersView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.usersView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat size = kAvatarSizeMin;
    CGFloat x = 0, y = (CGRectGetHeight(self.usersView.bounds) - size) / 2.0, right = marginX;
    CGFloat paddingX = -5;
    NSInteger count = userArray.count > defaultDisplayUsersCount ? defaultDisplayUsersCount : userArray.count;
    CGFloat userViewWidth = (count + 1) * kAvatarSizeMin - (count * -paddingX);
    self.usersView.width = userViewWidth;
    self.usersView.left = kScreenWidth - userViewWidth - right;
    
    for (int i = 0; i < count; i++) {
        WLUser *user = (WLUser *)userArray[i];
        
        WLHeadView *imgView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        imgView.frame = CGRectMake(x, y, size, size);
        imgView.userInteractionEnabled = NO;
        [imgView setHeadUrl:user.headUrl];
        [self.usersView addSubview:imgView];
        
        x += (size + paddingX);
    }
    
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, size, size)];
    allLabel.font = kBoldFont(kLightFontSize) ;
    allLabel.textColor = kClickableTextColor;
    allLabel.text = [AppContext getStringForKey:@"all" fileName:@"common"];
    allLabel.layer.cornerRadius = size * 0.5;
    allLabel.clipsToBounds = YES;
    allLabel.textAlignment = NSTextAlignmentCenter;
    allLabel.backgroundColor = [UIColor whiteColor];
    [self.usersView addSubview:allLabel];
}

#pragma mark - Event

- (void)usersViewOnTapped {
    if ([self.delegate respondsToSelector:@selector(topicInfoCellDidClickedUsers:)]) {
        [self.delegate topicInfoCellDidClickedUsers:self];
    }
}

#pragma mark - Getter

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.frame = CGRectMake(0, 0, kScreenWidth, kWLTopicInfoCellHeight);
        imgView.contentMode = UIViewContentModeScaleToFill;
        imgView.clipsToBounds = YES;
        _bgImgView = imgView;
    }
    return _bgImgView;
}

- (CALayer *)shadeLayer {
    if (!_shadeLayer) {
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        layer.frame = CGRectMake(0, 0, kScreenWidth, kWLTopicInfoCellHeight);
        _shadeLayer = layer;
    }
    return _shadeLayer;
}

- (CATextLayer *)titleLayer {
    if (!_titleLayer) {
        CATextLayer *txtLayer = [self textLayerWithFont:kBoldFont(24) textColor:[UIColor whiteColor]];
        txtLayer.frame = CGRectMake(marginX, 17, kScreenWidth - marginX * 2, 26);
        _titleLayer = txtLayer;
    }
    return _titleLayer;
}

- (CATextLayer *)userCountLayer {
    if (!_userCountLayer) {
        CATextLayer *txtLayer = [self textLayerWithFont:kBoldFont(16) textColor:[UIColor whiteColor]];
        txtLayer.frame = CGRectMake(marginX, _titleLayer.frame.origin.y + _titleLayer.frame.size.height + 6 , kScreenWidth - marginX * 2, 19);
        _userCountLayer = txtLayer;
    }
    return _userCountLayer;
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

- (UIView *)usersView {
    if (!_usersView) {
        CGFloat width = 120, height = 36;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - width, 80, width, height)];
        view.backgroundColor = [UIColor clearColor];
        _usersView = view;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usersViewOnTapped)];
        [view addGestureRecognizer:tap];
    }
    return _usersView;
}

@end
