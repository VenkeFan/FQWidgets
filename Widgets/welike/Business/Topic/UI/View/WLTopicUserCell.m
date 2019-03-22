//
//  WLTopicUserCell.m
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicUserCell.h"
#import "WLFollowButton.h"
#import "WLUser.h"
#import "WLAccountManager.h"
#import "NSDate+LuuBase.h"
#import "WLHeadView.h"

@interface WLTopicUserCell ()

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) CATextLayer *nameLayer;
@property (nonatomic, strong) CATextLayer *timeLayer;
@property (nonatomic, strong) CATextLayer *descLayer;
@property (nonatomic, strong) WLFollowButton *followBtn;

@property (nonatomic, strong) CALayer *separateLayer;

@end

@implementation WLTopicUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat avatarSize = kAvatarSizeMedium;
        
        _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarView.frame = CGRectMake(0, 0, avatarSize, avatarSize);
        _avatarView.userInteractionEnabled = NO;
        [self.contentView addSubview:_avatarView];
        
        _nameLayer = [self textLayerWithFont:kBoldFont(kMediumNameFontSize) textColor:kNameFontColor];
        [self.contentView.layer addSublayer:_nameLayer];
        
        _timeLayer = [self textLayerWithFont:[UIFont systemFontOfSize:kLightFontSize] textColor:kBodyFontColor];
        [self.contentView.layer addSublayer:_timeLayer];
        
        _descLayer = [self textLayerWithFont:[UIFont systemFontOfSize:kLightFontSize] textColor:kLightLightFontColor];
        [self.contentView.layer addSublayer:_descLayer];
        
        _followBtn = [[WLFollowButton alloc] init];
        _followBtn.width += 18;
        [self.contentView addSubview:_followBtn];
        
        _separateLayer = [CALayer layer];
        _separateLayer.backgroundColor = kSeparateLineColor.CGColor;
        [self.contentView.layer addSublayer:_separateLayer];
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
    
    CGFloat x= 15, paddingX = 10, paddingY = 5;
    
    _avatarView.center = CGPointMake(x + CGRectGetWidth(self.avatarView.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    _followBtn.center = CGPointMake(kScreenWidth - x - CGRectGetWidth(self.followBtn.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    
    x += (CGRectGetWidth(self.avatarView.bounds) + paddingX);
    CGFloat width = CGRectGetMinX(self.followBtn.frame) - x - paddingX;
    CGFloat y = CGRectGetMinY(self.avatarView.frame);
    
    _nameLayer.frame = CGRectMake(x, y, width, _nameLayer.fontSize + paddingY);
    y += CGRectGetHeight(_nameLayer.frame);
    
    _timeLayer.frame = CGRectMake(x, y, width, _timeLayer.fontSize + paddingY);
    y += CGRectGetHeight(_timeLayer.frame);
    
    _descLayer.frame = CGRectMake(x, y, width, _timeLayer.fontSize + paddingY);
    
    _separateLayer.frame = CGRectMake(x, CGRectGetHeight(self.bounds) - 1, CGRectGetMaxX(self.followBtn.frame) - x, 1);
}

- (void)setItemModel:(WLUser *)itemModel {
    [_avatarView setUser:itemModel];
    
    _nameLayer.string = itemModel.nickName;
    _timeLayer.string = [self timeStringFromTimestamp:itemModel.recentPostTime];
    _descLayer.string = itemModel.introduction;
    
    if ([itemModel.uid isEqualToString:[AppContext getInstance].accountManager.myAccount.uid]) {
        _followBtn.hidden = YES;
    } else {
        _followBtn.hidden = NO;
        [_followBtn setUser:itemModel];
    }
}

- (NSString *)timeStringFromTimestamp:(NSTimeInterval)timestamp {
    
    NSInteger timeNow = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger totalSeconds = timeNow - timestamp / 1000;
    
    NSString *result = nil;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    if (totalSeconds < 60) {
        result = [AppContext getStringForKey:@"topic_user_publish_just_now" fileName:@"topic"];;
    } else if (totalSeconds < 60 * 60) {
        result = [AppContext getStringForKey:@"topic_user_publish_minutes" fileName:@"topic"];
    } else if (totalSeconds < 60 * 60 * 24) {
        result = [AppContext getStringForKey:@"topic_user_publish_hours" fileName:@"topic"];
    } else {
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        result = [NSString stringWithFormat:[AppContext getStringForKey:@"topic_user_publish_day" fileName:@"topic"], [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]]];
    }
    
    return  result;
}

@end
