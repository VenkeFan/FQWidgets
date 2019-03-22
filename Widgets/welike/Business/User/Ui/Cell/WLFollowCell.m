//
//  WLFollowCell.m
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowCell.h"
#import "WLFollowButton.h"
#import "WLUser.h"
#import "WLAccountManager.h"
#import "WLHeadView.h"

@interface WLFollowCell ()

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) CATextLayer *nameLayer;
@property (nonatomic, strong) CATextLayer *descLayer;
@property (nonatomic, strong) CATextLayer *infoLayer;
@property (nonatomic, strong) WLFollowButton *followBtn;

@property (nonatomic, strong) CALayer *separateLayer;

@end

@implementation WLFollowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat avatarSize = 48.0;
        
        _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarView.frame = CGRectMake(0, 0, avatarSize, avatarSize);
        _avatarView.userInteractionEnabled = NO;
        [self.contentView addSubview:_avatarView];
        
        _nameLayer = [self textLayerWithFont:kBoldFont(kMediumNameFontSize) textColor:kNameFontColor];
        [self.contentView.layer addSublayer:_nameLayer];
        
        _descLayer = [self textLayerWithFont:kRegularFont(kLightFontSize) textColor:kLightLightFontColor];
        [self.contentView.layer addSublayer:_descLayer];
        
        _infoLayer = [self textLayerWithFont:kRegularFont(kLightFontSize) textColor:kLightLightFontColor];
        [self.contentView.layer addSublayer:_infoLayer];
        
        _followBtn = [[WLFollowButton alloc] init];
        _followBtn.width += 18;
        [self.contentView addSubview:_followBtn];
        
        _separateLayer = [CALayer layer];
        _separateLayer.backgroundColor = kSeparateLineColor.CGColor;
        [self.contentView.layer addSublayer:_separateLayer];
        
        self.contentView.clipsToBounds = YES;
    }
    
    return self;
}

- (CATextLayer *)textLayerWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.contentsScale = kScreenScale;
    txtLayer.alignmentMode = kCAAlignmentLeft;
    txtLayer.truncationMode = kCATruncationEnd;
    txtLayer.foregroundColor = textColor.CGColor;
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    txtLayer.font = fontRef;
    txtLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    return txtLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = 12, paddingX = 12, paddingY = 5;
    
    _avatarView.center = CGPointMake(x + CGRectGetWidth(self.avatarView.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    _followBtn.center = CGPointMake(kScreenWidth - x - CGRectGetWidth(_followBtn.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    
    x += (CGRectGetWidth(self.avatarView.bounds) + paddingX);
    CGFloat width = CGRectGetMinX(_followBtn.frame) - x - paddingX;
    if (_followBtn.hidden) {
        width += CGRectGetWidth(_followBtn.frame);
    }
    
    CGFloat y = CGRectGetMinY(self.avatarView.frame);
    
    _nameLayer.frame = CGRectMake(x, y, width, _nameLayer.fontSize + paddingY);
    y += CGRectGetHeight(_nameLayer.frame);
    
    _descLayer.frame = CGRectMake(x, y, width, _descLayer.fontSize + paddingY);
    y += CGRectGetHeight(_descLayer.frame);
    
    _infoLayer.frame = CGRectMake(x, y, width, _descLayer.fontSize + paddingY);
    
    _separateLayer.frame = CGRectMake(CGRectGetMinX(_nameLayer.frame), kFollowUserCellHeight - 1.0, CGRectGetMaxX(self.frame) - CGRectGetMinX(_nameLayer.frame), 1.0);
}

- (void)setItemModel:(WLUser *)itemModel {
    [_avatarView setUser:itemModel];
    
    _nameLayer.string = itemModel.nickName;
    _descLayer.string = itemModel.introduction;
    
    if (self.type == WELIKE_FOLLOW_CELL_TYPE_SEARCH) {
        _followBtn.hidden = YES;
        
        _infoLayer.string = [NSString stringWithFormat:@"%@: %ld  %ld %@",
                             [AppContext getStringForKey:@"mine_follower_num_text"
                                                fileName:@"user"],
                             (long)itemModel.followedUsersCount,
                             (long)itemModel.likedMyPostsCount,
                             [AppContext getStringForKey:@"mine_liked_num_text" fileName:@"user"]];
    } else {
        _followBtn.hidden = NO;
        
        _infoLayer.string = [NSString stringWithFormat:@"%@: %ld",
                             [AppContext getStringForKey:@"mine_follower_num_text"
                                                fileName:@"user"],
                             (long)itemModel.followedUsersCount];
        
        if ([itemModel.uid isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
            _followBtn.hidden = YES;
        } else {
            _followBtn.hidden = NO;
            [_followBtn setUser:itemModel];
        }
    }
}

@end
