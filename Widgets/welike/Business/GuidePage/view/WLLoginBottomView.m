//
//  WLLoginBottomView.m
//  welike
//
//  Created by gyb on 2018/8/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLoginBottomView.h"
#import "WLRegisterSelectLanguageViewController.h"
#import "WLRegisterMobileViewController.h"
#import "WLTrackerLogin.h"

@implementation WLLoginBottomView

- (instancetype)initWithFrame:(CGRect)frame withImageArray:(NSArray *)nameArray withTitleArray:(NSArray *)titleArray {
    if (self = [super initWithFrame:frame]) {
      
        CGFloat gap = (kScreenWidth - 46*nameArray.count)/4;
        
        for (int i = 0; i < nameArray.count; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(gap + i*gap + 46*i, (frame.size.height - (46 + 7 + 16))/2.0 - 15, 46, 46);
            [btn setImage:[AppContext getImageForKey:nameArray[i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            btn.showsTouchWhenHighlighted = YES;
            
            btn.tag = 10 + i;
            
            [self addSubview:btn];
            
            if (kIsiPhoneX)
            {
                btn.top =  (frame.size.height - (46 + 7 + 16))/2.0 - 30;
            }
            
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.bottom + 7, 80, 17)];
            titleLabel.text = titleArray[i];
            titleLabel.font = kRegularFont(14);
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = kNameFontColor;
            [self addSubview:titleLabel];
            titleLabel.centerX = btn.centerX;
        }
        
        UITextView *linkView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.height - 30, kScreenWidth, 40)];
        linkView.textAlignment = NSTextAlignmentCenter;
        linkView.font = kRegularFont(10);
        linkView.textColor = kDescriptionColor;
        linkView.backgroundColor = [UIColor clearColor];
        [self addSubview:linkView];
        
        
        NSString *protocolStr1 = [AppContext getStringForKey:@"regist_terms_service_ex2" fileName:@"register"];
        NSString *protocolStr2 = [AppContext getStringForKey:@"regist_terms_service" fileName:@"register"];
        NSString *protocolStr = [NSString stringWithFormat:@"%@%@",protocolStr1, protocolStr2];
       // CGFloat protocolWidth = [protocolStr sizeWithFont:linkView.font size:CGSizeMake(kScreenWidth, 18)].width;
        
        NSString *protocol = [[AppContext getDownloadHostName] stringByAppendingPathComponent:@"protocol.html"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:protocolStr];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kDescriptionColor range:[protocolStr rangeOfString:protocolStr1]];
        [attributedString addAttribute:NSLinkAttributeName value:protocol range:[[attributedString string] rangeOfString:protocolStr2]];
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: kClickableTextColor,
                                         NSUnderlineColorAttributeName: kClickableTextColor,
                                         NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
        linkView.attributedText = attributedString;
        linkView.linkTextAttributes = linkAttributes;
        linkView.textAlignment = NSTextAlignmentCenter;
        linkView.editable = NO;

        
        if (kIsiPhoneX)
        {
            linkView.top = self.height - 64;
        }
        
        
    }
    return self;
}


-(void)loginBtnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 10)
    {
        [_delagate clickFacebook];
        
        [WLTrackerLogin appendLoginBtnClicked:WLTrackerLoginType_Facebook
                                snsVerifyType:WLTrackerLoginSNSVerifyType_Login
                                loginPageType:WLTrackerLoginPageType_FullScreen
                            relateAccountType:WLTrackerLoginRelateAccountType_LoginBtn];
    }
    
    if (btn.tag == 11)
    {
        [_delagate clickGoogle];
        
        [WLTrackerLogin appendLoginBtnClicked:WLTrackerLoginType_Google
                                snsVerifyType:WLTrackerLoginSNSVerifyType_Login
                                loginPageType:WLTrackerLoginPageType_FullScreen
                            relateAccountType:WLTrackerLoginRelateAccountType_LoginBtn];
    }
    
    if (btn.tag == 12)
    {
        WLRegisterMobileViewController *ctr = [[WLRegisterMobileViewController alloc] init];
        [[AppContext rootViewController] pushViewController:ctr animated:YES];
        
        [WLTrackerLogin appendLoginBtnClicked:WLTrackerLoginType_Mobile
                                snsVerifyType:WLTrackerLoginSNSVerifyType_Login
                                loginPageType:WLTrackerLoginPageType_FullScreen
                            relateAccountType:WLTrackerLoginRelateAccountType_LoginBtn];
    }
}

@end
