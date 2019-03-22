//
//  WLArticalShareView.m
//  welike
//
//  Created by gyb on 2019/2/25.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalShareView.h"
#import "WLImageButton.h"
#import "WLShareManager.h"
#import "WLArticalPostModel.h"

#define kWhatsAppName               @"WhatsApp"
#define kFacebookName               @"Facebook"
#define kCopyLinkName               @"Copy"

@implementation WLArticalShareView

- (instancetype)initWithFrame:(CGRect)frame withBtnWidth:(CGFloat)btnWidth haveTitle:(BOOL)flag {
    if (self = [super initWithFrame:frame]) {

        CGFloat x = 0, paddingX = flag?20:20;

        UIControl *whatsBtn = [self buttonWithTitle:flag?kWhatsAppName:@"" withBtnWidth:btnWidth imageName:flag?@"share_whats":@"share_whats_40" x:x action:@selector(whatsBtnOnClicked)];
        [self addSubview:whatsBtn];
        x += (whatsBtn.frame.size.width + paddingX);
        
        UIControl *fbBtn = [self buttonWithTitle:flag?kFacebookName:@"" withBtnWidth:btnWidth imageName:flag?@"share_facebook":@"share_facebook_40" x:x action:@selector(facebookBtnOnClicked)];
        [self addSubview:fbBtn];
        x += (fbBtn.frame.size.width + paddingX);
        
        UIControl *copyBtn = [self buttonWithTitle:flag?kCopyLinkName:@"" withBtnWidth:btnWidth imageName:flag?@"share_link":@"share_link_40" x:x action:@selector(copyBtnOnClicked)];
        [self addSubview:copyBtn];
        
    }
    return self;
}

- (UIControl *)buttonWithTitle:(NSString *)title withBtnWidth:(CGFloat)btnWidth imageName:(NSString *)imageName x:(CGFloat)x action:(SEL)action {
    WLImageButton *btn = [[WLImageButton alloc] init];
    btn.frame = CGRectMake(x, 0, btnWidth, btnWidth);
    btn.imageOrientation = WLImageButtonOrientation_Top;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
    btn.titleLabel.font = kRegularFont(12);
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setImage:[AppContext getImageForKey:imageName] forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(8, 0, 0, 0)];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

-(void)setPostBase:(WLArticalPostModel *)postBase
{
    _postBase = postBase;
    
}

-(void)whatsBtnOnClicked
{
    if (!self.postBase) {
        return;
    }
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:self.postBase];
    
    [self.shareManager whatsAppShareWithShareModel:shareModel];
}

-(void)facebookBtnOnClicked
{
    
    if (!self.postBase) {
        return;
    }
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:self.postBase];
     [self.shareManager facebookShareWithShareModel:shareModel];
}

-(void)copyBtnOnClicked
{
    if (!self.postBase) {
        return;
    }
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:self.postBase];
    [self.shareManager copyLinkWithShareModel:shareModel];
}


- (WLShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[WLShareManager alloc] init];
//        _shareManager.currentViewCtr =  [AppContext currentViewController];
    }
    return _shareManager;
}





@end
