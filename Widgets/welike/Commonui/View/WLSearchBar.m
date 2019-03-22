//
//  WLSearchBar.m
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchBar.h"
#import "LOTAnimationView.h"
#import "RDLocalizationManager.h"

#define kSearchBarYMargin                8.f
#define kSearchBarXMargin                12.f
#define kSearchBarIconLeftMargin         12.f
#define kSearchBarIconRightMargin        7.f

@interface WLSearchBar ()

@property (nonatomic, copy) NSString *iconResId;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *rankBtn;



- (void)onClick;
- (void)onBack;

@end

@implementation WLSearchBar

- (id)initWithIcon:(NSString *)iconResId placeholder:(NSString *)placeholder
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kSearchBarHeight + kSystemStatusBarHeight)];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.iconResId = iconResId;
        self.placeholder = placeholder;
        self.showBack = NO;
        [self layout];
    }
    return self;
}

- (void)layout
{
    [self removeAllSubviews];
    
    if (self.showBack == YES)
    {
        if (self.backBtn == nil)
        {
            self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.backBtn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
            [self.backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        }
        self.backBtn.frame = CGRectMake(0, kSystemStatusBarHeight, self.height - kSystemStatusBarHeight, self.height - kSystemStatusBarHeight);
        [self addSubview:self.backBtn];
    }
    else
    {
        self.backBtn = nil;
    }
    
    if (self.searchBtn == nil)
    {
        self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.searchBtn.backgroundColor = kSearchEditorColor;
        self.searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        CGFloat iconWidth = 0;
        if ([self.iconResId length] > 0)
        {
            UIImage *icon = [AppContext getImageForKey:self.iconResId];
            iconWidth = icon.size.width;
            [self.searchBtn setImage:icon forState:UIControlStateNormal];
            [self.searchBtn setImage:icon forState:UIControlStateHighlighted];
            self.searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, kSearchBarIconLeftMargin, 0, 0);
        }
        self.searchBtn.titleLabel.font = [UIFont systemFontOfSize:kMediumNameFontSize];
        if (iconWidth > 0)
        {
            self.searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, kSearchBarIconLeftMargin + kSearchBarIconRightMargin, 0, 0);
        }
        else
        {
            self.searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, kSearchBarIconLeftMargin, 0, 0);
        }
        [self.searchBtn.layer setMasksToBounds:YES];
        [self.searchBtn.layer setCornerRadius:kCornerRadius];
        self.searchBtn.layer.borderWidth = 1;
        self.searchBtn.layer.borderColor = kSearchBorder.CGColor;
        
        [self.searchBtn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.backBtn == nil)
    {
        self.searchBtn.frame = CGRectMake(kSearchBarXMargin, kSearchBarYMargin + kSystemStatusBarHeight, self.width - kSearchBarXMargin * 2, self.height - (kSearchBarYMargin + kSystemStatusBarHeight) - kSearchBarYMargin);
    }
    else
    {
        self.searchBtn.frame = CGRectMake(self.backBtn.right, kSearchBarYMargin + kSystemStatusBarHeight, self.width - kSearchBarXMargin - self.backBtn.width, self.height - (kSearchBarYMargin + kSystemStatusBarHeight) - kSearchBarYMargin);
    }
    if ([self.content length] > 0)
    {
        [self.searchBtn setTitle:self.content forState:UIControlStateNormal];
        [self.searchBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
    }
    else if ([self.placeholder length] > 0)
    {
        [self.searchBtn setTitle:self.placeholder forState:UIControlStateNormal];
        [self.searchBtn setTitleColor:kPlaceHolderColor forState:UIControlStateNormal];
    }
    [self addSubview:self.searchBtn];
}

- (void)setContent:(NSString *)content
{
    _content = [content copy];
    [self layout];
}

- (void)setShowBack:(BOOL)showBack
{
    if (_showBack != showBack)
    {
        _showBack = showBack;
        [self layout];
    }
}

- (void)onClick
{
    if ([self.delegate respondsToSelector:@selector(onClickSearchBar:)])
    {
        [self.delegate onClickSearchBar:self];
    }
}

- (void)onBack
{
    if ([self.delegate respondsToSelector:@selector(onBackSearchBar:)])
    {
        [self.delegate onBackSearchBar:self];
    }
}

-(void)rankBtnPressed
{
    if ([self.delegate respondsToSelector:@selector(onClickRank)])
    {
        [self.delegate onClickRank];
    }
}


-(void)addRankBtn
{
    LOTAnimationView *animationView = [[LOTAnimationView alloc] init];
    animationView.backgroundColor = [UIColor clearColor];
    animationView.frame = CGRectMake(0, 0, self.height - kSystemStatusBarHeight, self.height - kSystemStatusBarHeight);
    animationView.center = CGPointMake(self.width - animationView.width * 0.5, kSystemStatusBarHeight + animationView.height * 0.5);
    if ([[[RDLocalizationManager getInstance] getCurrentLanguage] isEqualToString:LANGUAGE_TYPE_ENG]) {
        [animationView setAnimationNamed:@"en-data"];
    } else {
        [animationView setAnimationNamed:@"hin-data"];
    }
    animationView.loopAnimation = YES;
    [animationView play];
    [self addSubview:animationView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rankBtnPressed)];
    [animationView addGestureRecognizer:tap];
    
    self.searchBtn.width = self.width - animationView.width - kSearchBarXMargin;
}

@end
