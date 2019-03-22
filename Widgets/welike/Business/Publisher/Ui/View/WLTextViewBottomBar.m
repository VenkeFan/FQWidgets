//
//  WLTextViewBottomBar.m
//  welike
//
//  Created by gyb on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTextViewBottomBar.h"


@implementation WLTextViewBottomBar

-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame type:(WELIKE_DRAFT_TYPE)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        draftType = type;
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake([LuuUtils mainScreenBounds].width - 50 - 15, 0 , 50, 35)];
        countLabel.font = kMediumFont(15);
        countLabel.text = @"";
        countLabel.textColor = kLightLightFontColor;
        countLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:countLabel];
        
        UIImageView  *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, countLabel.bottom - 3, [LuuUtils mainScreenBounds].width, 48)];
        bgView.image = [AppContext getImageForKey:@"publish_bottom_bar"];
        [self addSubview:bgView];
        
        emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        emojiBtn.frame = CGRectMake(0, 38, bottom_bar_btn_size.width, bottom_bar_btn_size.height);
        [emojiBtn setImage:[AppContext getImageForKey:@"publisher_emoji"] forState:UIControlStateNormal];
        //        [emojiBtn setImage:[AppContext getImageForKey:@"publish_emoji_h"] forState:UIControlStateHighlighted];
        [emojiBtn addTarget:self action:@selector(emojiBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:emojiBtn];
        
        contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contactBtn.frame = CGRectMake(emojiBtn.right, emojiBtn.top, bottom_bar_btn_size.width, bottom_bar_btn_size.height);
        [contactBtn setImage:[AppContext getImageForKey:@"publisher_inform"] forState:UIControlStateNormal];
//        [contactBtn setImage:[AppContext getImageForKey:@"publish_about_h"] forState:UIControlStateHighlighted];
        [contactBtn addTarget:self action:@selector(contactBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contactBtn];
        
        topicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        topicBtn.frame = CGRectMake(contactBtn.right, contactBtn.top, bottom_bar_btn_size.width, bottom_bar_btn_size.height);
        [topicBtn setImage:[AppContext getImageForKey:@"publisher_hashtag"] forState:UIControlStateNormal];
//        [topicBtn setImage:[AppContext getImageForKey:@"publish_topic_h"] forState:UIControlStateHighlighted];
        [topicBtn addTarget:self action:@selector(topicBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:topicBtn];
        
        linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        linkBtn.frame = CGRectMake(topicBtn.right, topicBtn.top, bottom_bar_btn_size.width, bottom_bar_btn_size.height);
        [linkBtn setImage:[AppContext getImageForKey:@"publisher_link"] forState:UIControlStateNormal];
//        [linkBtn setImage:[AppContext getImageForKey:@"publish_link_h"] forState:UIControlStateHighlighted];
        [linkBtn addTarget:self action:@selector(linkBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:linkBtn];
        
        emojiBtn.imageEdgeInsets = UIEdgeInsetsMake((44 - 28)/2.0 - 2.5, (44 - 28)/2.0, (44 - 28)/2.0 + 2.5, (44 - 28)/2.0);
        contactBtn.imageEdgeInsets = emojiBtn.imageEdgeInsets;
        topicBtn.imageEdgeInsets = emojiBtn.imageEdgeInsets;
        linkBtn.imageEdgeInsets = emojiBtn.imageEdgeInsets;
        
        
        publishCheckBox = [[WLPublishCheckBox alloc] initWithFrame:CGRectMake(5, 0, 150, 35) type:type];
        [self addSubview:publishCheckBox];

//        sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        sendBtn.frame = CGRectMake([LuuUtils mainScreenBounds].width - 15 - 56, 35 + (44 - 24)/2.0, 56, 24);
//        sendBtn.showsTouchWhenHighlighted = YES;
//        [sendBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
//        [sendBtn setTitle:[AppContext getStringForKey:@"editor_post_send" fileName:@"publish"] forState:UIControlStateNormal];
//        sendBtn.titleLabel.font = kBoldFont(14);
//        sendBtn.backgroundColor = kLargeBtnDisableColor;
//        sendBtn.layer.cornerRadius = 3;
//        [sendBtn addTarget:self action:@selector(sendBtnPressed) forControlEvents:UIControlEventTouchUpInside];
//        sendBtn.adjustsImageWhenDisabled = NO;
//        [self addSubview:sendBtn];
//        sendBtn.enabled = NO;
        
        //默认发送不可点,转发情况除外
//         if (draftType == WELIKE_DRAFT_TYPE_FORWARD_POST || draftType == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
//         {
//             sendBtn.enabled = YES;
//             sendBtn.backgroundColor = kMainColor;
//             [sendBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
//         }
        
    }
    return self;
}



-(void)camareBtnPressed
{
    [_delegate camareBtn];
}

-(void)contactBtnPressed
{
    [_delegate contactBtn];
}

-(void)emojiBtnPressed
{
    [_delegate emojiBtn];
}

-(void)linkBtnPressed
{
    [_delegate linkBtn];
}

-(void)voteBtnPressed
{
    [_delegate voteBtn];
}

-(void)sendBtnPressed
{
    [_delegate sendBtnPressed];
}

-(void)topicBtnPressed
{
    [_delegate topicBtn];
}

-(void)changeToEmojiStatus:(BOOL)flag
{
    if (flag)
    {
        [emojiBtn setImage:[AppContext getImageForKey:@"publish_keyboard"] forState:UIControlStateNormal];
       
    }
    else
    {
        [emojiBtn setImage:[AppContext getImageForKey:@"publisher_emoji"] forState:UIControlStateNormal];
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

-(void)changeCharNum:(NSInteger)num
{
    if (num == 0)
    {
        countLabel.text = @"";
        countLabel.textColor = charNumColorGrey;
        
        if (draftType == WELIKE_DRAFT_TYPE_FORWARD_POST || draftType == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
              [self enableSendeBtn];
        }
        else
        {
              [self disableSendBtn];
        }
    }
    
    if (num > 0 && num <= 275)
    {
        countLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
        countLabel.textColor = charNumColorGrey;
        [self enableSendeBtn];
    }
    
    if (num > 275 && num <= 1000)
    {
      
    
        if (draftType == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY || draftType == WELIKE_DRAFT_TYPE_REPLY || draftType == WELIKE_DRAFT_TYPE_COMMENT)
        {
              countLabel.text = [NSString stringWithFormat:@"-%ld",(long)(num-275)];
              countLabel.textColor = charNumColorRed;
              [self disableSendBtn];
        }
        else
        {
            countLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
            countLabel.textColor = charNumColorOrange;
            [self enableSendeBtn];
        }
    }
    
    if (num > 1000)
    {
        if (draftType == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY || draftType == WELIKE_DRAFT_TYPE_REPLY || draftType == WELIKE_DRAFT_TYPE_COMMENT)
        {
            countLabel.text = [NSString stringWithFormat:@"-%ld",(long)(num-275)];
            countLabel.textColor = charNumColorRed;
            [self disableSendBtn];
        }
        else
        {
            countLabel.text = [NSString stringWithFormat:@"-%ld",(long)(num-1000)];
            countLabel.textColor = charNumColorRed;
            [self disableSendBtn];
        }
    }
    
}

-(BOOL)sendEnabled
{
    return sendBtn.enabled;
}


-(BOOL)isCheck
{
    return publishCheckBox.isCheck;
}

-(void)selectCheckBox
{
    [publishCheckBox select];
}

-(void)enableTopicBtn
{
    [topicBtn setImage:[AppContext getImageForKey:@"publisher_hashtag"] forState:UIControlStateNormal];
}

-(void)disableTopicBtn
{
    [topicBtn setImage:[AppContext getImageForKey:@"publish_icon_unclick_topic"] forState:UIControlStateNormal];
}


-(void)enableAllBtn
{
//    camareBtn.enabled = YES;
    contactBtn.enabled = YES;
    topicBtn.enabled = YES;
    emojiBtn.enabled = YES;
    linkBtn.enabled = YES;
//    voteBtn.enabled = YES;
    
}

-(void)disableAllBtn
{
//    camareBtn.enabled = NO;
    contactBtn.enabled = NO;
    topicBtn.enabled = NO;
    emojiBtn.enabled = NO;
    linkBtn.enabled = NO;
//    voteBtn.enabled = NO;
    
}

-(void)enableALLBtnExceptVoteBtn
{
//    camareBtn.enabled = YES;
    contactBtn.enabled = YES;
    topicBtn.enabled = YES;
    emojiBtn.enabled = YES;
    linkBtn.enabled = YES;
//    voteBtn.enabled = NO;
    
    
}

-(void)enableALLBtnExceptVoteAndPhotoBtn
{
//    camareBtn.enabled = NO;
    contactBtn.enabled = YES;
    topicBtn.enabled = YES;
    emojiBtn.enabled = YES;
    linkBtn.enabled = YES;
//    voteBtn.enabled = NO;
}






@end
