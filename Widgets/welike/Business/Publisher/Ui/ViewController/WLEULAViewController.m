//
//  WLEULAViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLEULAViewController.h"

#define kButtonHeight                     40.f
#define kButtonBottom                     16.f
#define kButtonXBreak                     16.f

@interface WLEULAViewController ()

@end

@implementation WLEULAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, kSystemStatusBarHeight, self.view.width, kSingleNavBarHeight)];
    title.font = [UIFont systemFontOfSize:kNameFontSize];
    title.textColor = kNameFontColor;
    title.textAlignment = NSTextAlignmentCenter;
    title.text = [AppContext getStringForKey:@"post_eula_title" fileName:@"publish"];
    [self.view addSubview:title];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, title.bottom, self.view.width, 0.5f)];
    line.backgroundColor = kSeparateLineColor;
    [self.view addSubview:line];
    
    CGFloat width = (self.view.width - kButtonXBreak - kLargeBtnXMargin * 2) / 2.f;
    
    UIButton *accept = [UIButton buttonWithType:UIButtonTypeCustom];
    accept.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kButtonHeight - kButtonBottom - kSafeAreaBottomY, width, kButtonHeight);
    [accept setTitle:[AppContext getStringForKey:@"post_eula_accept" fileName:@"publish"] forState:UIControlStateNormal];
    [accept.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [accept setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [accept setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [accept.layer setMasksToBounds:YES];
    [accept.layer setCornerRadius:20.f];
    [accept addTarget:self action:@selector(onAccept) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accept];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(accept.right + kButtonXBreak, self.view.bottom - kButtonHeight - kButtonBottom - kSafeAreaBottomY, width, kButtonHeight);
    [cancel setTitle:[AppContext getStringForKey:@"post_eula_cancel" fileName:@"publish"] forState:UIControlStateNormal];
    [cancel.titleLabel setFont:[UIFont systemFontOfSize:kNameFontSize]];
    [cancel setTitleColor:kNameFontColor forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageWithColor:kLightBackgroundViewColor] forState:UIControlStateNormal];
    [cancel.layer setMasksToBounds:YES];
    [cancel.layer setCornerRadius:20.f];
    [cancel addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];

    NSString *protocol = [[AppContext getDownloadHostName] stringByAppendingPathComponent:@"protocol.html"];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, line.bottom + 30.f, self.view.width - kLargeBtnXMargin * 2.f, self.view.height - kNavBarHeight - 1.f - (kButtonHeight + kButtonBottom + kSafeAreaBottomY) - 40.f)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[AppContext getStringForKey:@"post_eula_content" fileName:@"publish"]];
    [attributedString addAttribute:NSLinkAttributeName value:protocol range:[[attributedString string] rangeOfString:[AppContext getStringForKey:@"post_eula_link" fileName:@"publish"]]];
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: kClickableTextColor,
                                     NSUnderlineColorAttributeName: kClickableTextColor,
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    textView.textAlignment = NSTextAlignmentCenter;
    textView.linkTextAttributes = linkAttributes;
    textView.attributedText = attributedString;
    textView.font = [UIFont systemFontOfSize:kNameFontSize];
    textView.editable = NO;
    [self.view addSubview:textView];
}

- (void)onAccept
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (self.accept)
    {
        self.accept();
    }
}

- (void)onCancel
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (self.cancel)
    {
        self.cancel();
    }
}

@end
