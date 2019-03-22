//
//  WLMessageBox.m
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageBox.h"
#import "WLBadgeView.h"

#define kMessageBoxTitleHeight                     18.f
#define kMessageBoxIconBottomMargin                3.f
#define kMessageBoxBadgeSize                       18.f

@interface WLMessageBox ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) WLBadgeView *badgeView;

@end

@implementation WLMessageBox

- (id)initWithFrame:(CGRect)frame iconResId:(NSString *)iconResId title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *icon = [AppContext getImageForKey:iconResId];
        CGFloat contentHeight = icon.size.height + kMessageBoxIconBottomMargin + kMessageBoxTitleHeight;
        CGFloat y = (self.height - contentHeight) / 2.f;
        
        self.iconView = [[UIImageView alloc] initWithImage:icon];
        self.iconView.frame = CGRectMake((self.width - icon.size.width) / 2.f, y, icon.size.width, icon.size.height);
        [self addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconView.bottom + kMessageBoxIconBottomMargin, self.width, kMessageBoxTitleHeight)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = kWeightTitleFontColor;
        self.titleLabel.font = [UIFont systemFontOfSize:kNoteFontSize];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];
        
        self.badgeView = [[WLBadgeView alloc] initWithParentView:self.iconView size:kMessageBoxBadgeSize fontSize:kSmallBadgeNumFontSize];
        self.badgeView.adjustX = -3.f;
        self.badgeView.adjustY = 3.f;
        self.badgeView.hidden = YES;
        
        [self addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setBadgeNum:(NSUInteger)badgeNum
{
    if (badgeNum > 0)
    {
        self.badgeView.hidden = NO;
        self.badgeView.badgeNumber = badgeNum;
    }
    else
    {
        self.badgeView.badgeNumber = 0;
        self.badgeView.hidden = YES;
    }
}

- (void)onClick
{
    if ([self.delegate respondsToSelector:@selector(onClick:)])
    {
        [self.delegate onClick:self];
    }
}

@end
