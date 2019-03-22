//
//  WLNotificationSettingSectionView.m
//  welike
//
//  Created by luxing on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNotificationSettingSectionView.h"

#define kNotificationSettingSectionTitleHeight                   30.0
#define kNotificationSettingSectionTitleHeightFont               14.0
#define kNotificationSettingSectionTitleColor                    kUIColorFromRGB(0xAFB0B1)

@interface WLNotificationSettingSectionView ()

@property (nonatomic,strong) UILabel *sectionLabel;

@end

@implementation WLNotificationSettingSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sectionLabel = [[UILabel alloc] init];
        _sectionLabel.frame = CGRectMake(kSettingCellMarginX, CGRectGetHeight(frame)-kNotificationSettingSectionTitleHeight, CGRectGetWidth(frame)-2*kSettingCellMarginX,kNotificationSettingSectionTitleHeight);
        _sectionLabel.textColor = kNotificationSettingSectionTitleColor;
        _sectionLabel.font = [UIFont systemFontOfSize:kNotificationSettingSectionTitleHeightFont];
        _sectionLabel.numberOfLines = 1;
        _sectionLabel.textAlignment = NSTextAlignmentLeft;
        _sectionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_sectionLabel];
    }
    return self;
}

- (void)setSectionTitle:(NSString *)title
{
    self.sectionLabel.text = title;
}

@end
