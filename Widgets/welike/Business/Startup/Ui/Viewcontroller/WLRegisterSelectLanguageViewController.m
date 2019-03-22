//
//  WLRegisterSelectLanguageViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterSelectLanguageViewController.h"
#import "WLStartHandler.h"
#import "WLLanguageCard.h"
#import "WLRegLikeIcon.h"
#import "RDLocalizationManager.h"
#import "WLTrackerLanguage.h"

#define kProtocolLinkHeight                     22.f
#define kLanguageCardHeight                     102.f
#define kLanguageCardCenterMargin               11.f
#define kLanguageSelTitleHeight                 18.f
#define kLanguageSelTitleBottomMargin           20.f
#define kProtocolCheckBoxSize                   35.f
#define kProtocolBottomMargin                   10.f

//@interface WLRegisterProtocolLinkView : UITextView
//
//@property (nonatomic, readonly) CGFloat protocolWidth;
//
//- (id)initWithWidth:(CGFloat)width;
//
//@end

@implementation WLRegisterProtocolLinkView

- (id)initWithWidth:(CGFloat)width
{
    UIFont *linkFont = [UIFont systemFontOfSize:kLinkFontSize];
    NSString *protocolStr1 = [AppContext getStringForKey:@"regist_terms_service_ex" fileName:@"register"];
    NSString *protocolStr2 = [AppContext getStringForKey:@"regist_terms_service" fileName:@"register"];
    NSString *protocolStr = [NSString stringWithFormat:protocolStr1, protocolStr2];
    CGFloat protocolWidth = [protocolStr sizeWithFont:linkFont size:CGSizeMake(width, kProtocolLinkHeight)].width;

    self = [super initWithFrame:CGRectMake(0, 0, protocolWidth, kProtocolLinkHeight)];
    if (self)
    {
        _protocolWidth = protocolWidth;
        self.textColor = kLightLightFontColor;
        self.font = linkFont;
        
        NSString *protocol = [[AppContext getDownloadHostName] stringByAppendingPathComponent:@"protocol.html"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:protocolStr];
        [attributedString addAttribute:NSLinkAttributeName value:protocol range:[[attributedString string] rangeOfString:protocolStr2]];
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: kClickableTextColor,
                                         NSUnderlineColorAttributeName: kClickableTextColor,
                                         NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
        self.textAlignment = NSTextAlignmentCenter;
        self.linkTextAttributes = linkAttributes;
        self.attributedText = attributedString;
        self.editable = NO;
    }
    return self;
}

@end

@interface WLRegisterSelectLanguageViewController () <WLStartHandlerDelegate, WLLanguageCardDelegate>

@property (nonatomic, strong) WLLanguageCard *enCard;
@property (nonatomic, strong) WLLanguageCard *hiCard;
@property (nonatomic, strong) UIButton *checkBox;
@property (nonatomic, strong) UIButton *nextBtn;

- (void)onNext;

@end

@implementation WLRegisterSelectLanguageViewController

- (void)loadView
{
    [super loadView];
    
    [self layout];
    
    NSString *lanType = [[RDLocalizationManager getInstance] getCurrentSystemLanguage];
    if ([lanType isEqualToString:LANGUAGE_TYPE_ENG] == YES)
    {
        [self.enCard setSelected:YES];
        [self.hiCard setSelected:NO];
    }
    else if ([lanType isEqualToString:LANGUAGE_TYPE_HINDI] == YES)
    {
        [self.hiCard setSelected:YES];
        [self.enCard setSelected:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppContext getInstance].startHandler registerWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppContext getInstance].startHandler unregister:self];
}

- (void)layout
{
    [self.view removeAllSubviews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    WLRegLikeIcon *topIcon = [[WLRegLikeIcon alloc] initWithFrame:CGRectMake(0, 35.f, 0, 0)];
    topIcon.right = self.view.width - kLargeBtnXMargin;
    [self.view addSubview:topIcon];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"welike_reg_logo"]];
    if ([LuuUtils mainScreenBounds].width <= 640)
    {
        logo.top = kRegisterLogoTopMargin_smal;
    }
    else
    {
        logo.top = kRegisterLogoTopMargin_larg;
    }
    logo.left = (self.view.width - logo.width) / 2.f;
    [self.view addSubview:logo];
    
    self.checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
    self.checkBox.frame = CGRectMake(0, self.view.bottom - kProtocolBottomMargin - kProtocolCheckBoxSize - kSafeAreaBottomY, kProtocolCheckBoxSize, kProtocolCheckBoxSize);
    [self.checkBox setImage:[AppContext getImageForKey:@"small_check_select"] forState:UIControlStateSelected];
    [self.checkBox setImage:[AppContext getImageForKey:@"small_check"] forState:UIControlStateNormal];
    [self.checkBox addTarget:self action:@selector(onCheckBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.checkBox];
    
    WLRegisterProtocolLinkView *protocolView = [[WLRegisterProtocolLinkView alloc] initWithWidth:(self.view.width - kRegisterLeftMargin - self.checkBox.width)];
    CGFloat pWidth = protocolView.protocolWidth + self.checkBox.width;
    CGFloat px = (self.view.width - pWidth) / 2.f;
    
    self.checkBox.left = px;
    protocolView.left = self.checkBox.right;
    protocolView.bottom = self.checkBox.bottom - (self.checkBox.height - protocolView.height) / 2.f - 4.f;
    [self.view addSubview:protocolView];
    
    NSString *nextTitle = [AppContext getStringForKey:@"regist_get_start" fileName:@"register"];
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kScreenHeight > 480)
    {
        self.nextBtn.frame = CGRectMake(kLargeBtnXMargin, self.checkBox.top - kLargeBtnHeight - kLargeBtnYMargin, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    }
    else
    {
        self.nextBtn.frame = CGRectMake(kLargeBtnXMargin, self.checkBox.top - kLargeBtnHeight, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    }
    [self.nextBtn setTitle:nextTitle forState:UIControlStateNormal];
    [self.nextBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.nextBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
    [self.nextBtn setEnabled:NO];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.nextBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];
    
    UILabel *selTitle = [[UILabel alloc] initWithFrame:CGRectMake(kRegisterLeftMargin, self.view.center.y, self.view.width - kRegisterLeftMargin * 2, kLanguageSelTitleHeight)];
    selTitle.backgroundColor = [UIColor clearColor];
    selTitle.textColor = kBodyFontColor;
    selTitle.textAlignment = NSTextAlignmentLeft;
    selTitle.text = [AppContext getStringForKey:@"regist_select_language" fileName:@"register"];
    selTitle.font = [UIFont systemFontOfSize:kNoteFontSize];
    [self.view addSubview:selTitle];

    CGFloat languageCardWidth = ceil((self.view.width - kRegisterLeftMargin * 2 - kLanguageCardCenterMargin) / 2.f);
    if (self.enCard == nil)
    {
        self.enCard = [[WLLanguageCard alloc] initWithFrame:CGRectMake(kRegisterLeftMargin, selTitle.bottom + kLanguageSelTitleBottomMargin, languageCardWidth, kLanguageCardHeight) icon:[AppContext getImageForKey:@"en_icon"] language:[AppContext getStringForKey:@"regist_choose_language_english" fileName:@"register"]];
    }
    self.enCard.delegate = self;
    [self.view addSubview:self.enCard];
    if (self.hiCard == nil)
    {
        self.hiCard = [[WLLanguageCard alloc] initWithFrame:CGRectMake(self.view.width - kRegisterLeftMargin - languageCardWidth, selTitle.bottom + kLanguageSelTitleBottomMargin, languageCardWidth, kLanguageCardHeight) icon:[AppContext getImageForKey:@"hi_icon"] language:[AppContext getStringForKey:@"regist_choose_language_hindi" fileName:@"register"]];
    }
    self.hiCard.delegate = self;
    [self.view addSubview:self.hiCard];
}

- (void)onCheckBox
{
    if (self.checkBox.isSelected == NO)
    {
        [self.checkBox setSelected:YES];
    }
    else
    {
        [self.checkBox setSelected:NO];
    }
    if (self.checkBox.isSelected == YES)
    {
        [self.nextBtn setEnabled:YES];
    }
    else
    {
        [self.nextBtn setEnabled:NO];
    }
}

- (void)onNext
{
    if (self.enCard.isSelected)
    {
        [[RDLocalizationManager getInstance] switchLanguage:LANGUAGE_TYPE_ENG];
        
        [WLTrackerLanguage appendTrackerWithLang:LANGUAGE_TYPE_ENG source:WLTrackerLanguageSource_Home];
    }
    else if (self.hiCard.isSelected)
    {
        [[RDLocalizationManager getInstance] switchLanguage:LANGUAGE_TYPE_HINDI];
        
        [WLTrackerLanguage appendTrackerWithLang:LANGUAGE_TYPE_HINDI source:WLTrackerLanguageSource_Home];
    }
    [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_LANG_DONE];
}

#pragma mark WLRegisterProtocolLinkView methods
- (void)onProtocolClicked
{
    NSString *protocol = [[AppContext getDownloadHostName] stringByAppendingPathComponent:@"protocol.html"];
    NSURL *uri = [NSURL URLWithString:protocol];
    [[UIApplication sharedApplication] openURL:uri];
}

#pragma mark WLLanguageCardDelegate methods
- (void)languageCardClicked:(WLLanguageCard *)card
{
    if (card == self.enCard)
    {
        [self.enCard setSelected:YES];
        [self.hiCard setSelected:NO];
    }
    else if (card == self.hiCard)
    {
        [self.hiCard setSelected:YES];
        [self.enCard setSelected:NO];
    }
}

#pragma mark WLStartHandlerDelegate methods
- (void)goProcess:(WELIKE_STARTUP_STATE)state
{
    [[AppContext getInstance].startHandler runNext:state];
}

@end
