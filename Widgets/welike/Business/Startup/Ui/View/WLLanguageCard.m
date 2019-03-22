//
//  WLLanguageCard.m
//  welike
//
//  Created by 刘斌 on 2018/4/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLanguageCard.h"
#import "AppContext.h"
#import "UIView+LuuBase.h"
#import "WLUIResourceDefine.h"

#define kLanguageCardLanguageLeftMargin  8.f
#define kLanguageCardCoverHeight         28.f
#define kLanguageCardCheckBoxtopMargin   8.f

@interface WLLanguageCard ()

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, strong) UIButton *checkBox;

- (void)layout;

@end

@implementation WLLanguageCard

- (id)initWithFrame:(CGRect)frame icon:(UIImage *)icon language:(NSString *)language;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.icon = icon;
        self.language = language;
        [self layout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self.checkBox setSelected:selected];
}

- (void)layout
{
    [self removeAllSubviews];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:self.icon];
    iconView.left = (self.width - iconView.width) / 2.f;
    iconView.top = (self.height - iconView.height) / 2.f;
    [self addSubview:iconView];
    
    UIFont *languageFont = [UIFont systemFontOfSize:kBodyFontSize];
    CGSize languageSize = [self.language sizeWithFont:languageFont size:CGSizeMake(self.width, kLanguageCardCoverHeight)];
    UILabel *languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLanguageCardLanguageLeftMargin, kLanguageCardCheckBoxtopMargin, languageSize.width, languageSize.height)];
    languageLabel.backgroundColor = [UIColor clearColor];
    languageLabel.textColor = kNameFontColor;
    languageLabel.textAlignment = NSTextAlignmentCenter;
    languageLabel.font = languageFont;
    languageLabel.text = self.language;
    [self addSubview:languageLabel];
    
    UIImage *uncheckImg = [AppContext getImageForKey:@"normal_checkbox_unselected"];
    UIImage *checkImg = [AppContext getImageForKey:@"normal_checkbox_selected"];
    self.checkBox = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kLanguageCardCheckBoxtopMargin - uncheckImg.size.width, kLanguageCardCheckBoxtopMargin, uncheckImg.size.width, uncheckImg.size.height)];
    [self.checkBox setBackgroundImage:uncheckImg forState:UIControlStateNormal];
    [self.checkBox setBackgroundImage:checkImg forState:UIControlStateSelected];
    [self.checkBox addTarget:self action:@selector(clickCheckBox) forControlEvents:UIControlEventTouchUpInside];
    [self.checkBox setSelected:NO];
    [self addSubview:self.checkBox];
    
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 5.f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(-0.5f, 2.f);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.2f;
    
    [self addTarget:self action:@selector(onTouched) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onTouched
{
    if ([self.delegate respondsToSelector:@selector(languageCardClicked:)])
    {
        [self.delegate languageCardClicked:self];
    }
}

- (void)clickCheckBox
{
    if ([self.delegate respondsToSelector:@selector(languageCardClicked:)])
    {
        [self.delegate languageCardClicked:self];
    }
}

@end
