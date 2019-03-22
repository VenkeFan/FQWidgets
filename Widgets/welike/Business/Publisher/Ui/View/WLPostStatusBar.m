//
//  WLPostStatusBar.m
//  welike
//
//  Created by gyb on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPostStatusBar.h"

@implementation WLPostStatusBar

-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
        self.layer.shadowOffset = CGSizeMake(0, -1);
        self.layer.shadowOpacity = 0.1;
        self.layer.shadowPath = CGPathCreateWithRect(CGRectMake(0, 0, kScreenWidth, 3), NULL);
        self.backgroundColor = [UIColor whiteColor];
        
        emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        emojiBtn.frame = CGRectMake(12, 0, 44, 49);
        [emojiBtn setImage:[AppContext getImageForKey:@"Post_status_emoji"] forState:UIControlStateNormal];
        emojiBtn.titleLabel.font = kRegularFont(12);
        [emojiBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [emojiBtn addTarget:self action:@selector(emojiBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:emojiBtn];
        
        photoBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        photoBtn.frame = CGRectMake(emojiBtn.right, 0, 44, 49);
        [photoBtn setImage:[AppContext getImageForKey:@"Post_status_pic"] forState:UIControlStateNormal];
        photoBtn.titleLabel.font = kRegularFont(12);
        [photoBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [photoBtn addTarget:self action:@selector(photoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:photoBtn];
        
        downloadBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.frame = CGRectMake(photoBtn.right, 0, 44, 49);;
        [downloadBtn setImage:[AppContext getImageForKey:@"Post_status_download"] forState:UIControlStateNormal];
        downloadBtn.titleLabel.font = kRegularFont(12);
        [downloadBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [downloadBtn addTarget:self action:@selector(downloadBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:downloadBtn];
        
        sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(kScreenWidth - 12 - 56, (49 - 24)/2.0, 56, 24);
        sendBtn.showsTouchWhenHighlighted = YES;
        [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
        [sendBtn setTitle:[AppContext getStringForKey:@"editor_post_send" fileName:@"publish"] forState:UIControlStateNormal];
        sendBtn.titleLabel.font = kBoldFont(14);
        sendBtn.backgroundColor = kLargeBtnDisableColor;
        sendBtn.layer.cornerRadius = 12;
        [sendBtn addTarget:self action:@selector(sendBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        sendBtn.adjustsImageWhenDisabled = NO;
        [self addSubview:sendBtn];
  
        
        
    }
    return self;
}

-(void)emojiBtnPressed
{
    if ([self.delegate respondsToSelector:@selector(emojiBtnPressed)])
    {
        [self.delegate emojiBtnPressed];
    }
}

-(void)photoBtnPressed
{
    if ([self.delegate respondsToSelector:@selector(photoBtnPressed)])
    {
         [self.delegate photoBtnPressed];
    }
}

-(void)downloadBtnPressed
{
    if ([self.delegate respondsToSelector:@selector(downloadBtnPressed)])
    {
         [self.delegate downloadBtnPressed];
    }
}

-(void)sendBtnPressed
{
    [self disableSendBtn];
    if ([self.delegate respondsToSelector:@selector(sendBtnPressed)])
    {
        [self.delegate sendBtnPressed];
    }
}

-(void)enableSendeBtn
{
    sendBtn.enabled = YES;
    [sendBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
    sendBtn.backgroundColor = kMainColor;
}


-(void)disableSendBtn
{
    sendBtn.enabled = NO;
    [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
    sendBtn.backgroundColor = kLargeBtnDisableColor;
}


@end
