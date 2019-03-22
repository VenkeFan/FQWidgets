//
//  WLPostBottomView.m
//  welike
//
//  Created by gyb on 2018/11/5.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPostBottomView.h"

@implementation WLPostBottomView

-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
//        self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
//        self.layer.shadowOffset = CGSizeMake(0, -1);
//        self.layer.shadowOpacity = 0.1;
//        self.layer.shadowPath = CGPathCreateWithRect(self.bounds, NULL);
//
        locationView = [[WLLocationView alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 50 - 15 - 15, 35)];
        locationView.delegate = self;
        [self addSubview:locationView];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake([LuuUtils mainScreenBounds].width - 50 - 15, 0 , 50, 35)];
        countLabel.font = kMediumFont(15);
        countLabel.text = @"";
        countLabel.textColor = kLightLightFontColor;
        countLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:countLabel];
        
        UIImage *shadowImage = [AppContext getImageForKey:@"shadow"];
        
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 36 - shadowImage.size.height, kScreenWidth, shadowImage.size.height)];
        shadowView.image = [shadowImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
         [self addSubview:shadowView];
        
        photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        photoBtn.frame = CGRectZero;
        [photoBtn setImage:[AppContext getImageForKey:@"publisher_image"] forState:UIControlStateNormal];
        [photoBtn setTitle:[AppContext getStringForKey:@"short_cut_alumb_name" fileName:@"publish"] forState:UIControlStateNormal];
        photoBtn.titleLabel.font = kRegularFont(12);
        [photoBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [photoBtn addTarget:self action:@selector(photoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:photoBtn];
        
        camareBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        camareBtn.frame = CGRectZero;
        [camareBtn setImage:[AppContext getImageForKey:@"publisher_inform_camera"] forState:UIControlStateNormal];
          [camareBtn setTitle:[AppContext getStringForKey:@"short_cut_snapshot_name" fileName:@"publish"] forState:UIControlStateNormal];
         camareBtn.titleLabel.font = kRegularFont(12);
          [camareBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [camareBtn addTarget:self action:@selector(camareBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:camareBtn];
        
        videoBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        videoBtn.frame = CGRectZero;
        [videoBtn setImage:[AppContext getImageForKey:@"publisher_video"] forState:UIControlStateNormal];
        [videoBtn setTitle:[AppContext getStringForKey:@"short_cut_video_name" fileName:@"publish"]forState:UIControlStateNormal];
       videoBtn.titleLabel.font = kRegularFont(12);
          [videoBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [videoBtn addTarget:self action:@selector(videoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:videoBtn];
        
        
        
        voteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voteBtn.frame = CGRectZero;
        [voteBtn setImage:[AppContext getImageForKey:@"publisher_poll"] forState:UIControlStateNormal];
         [voteBtn setTitle:[AppContext getStringForKey:@"short_cut_poll_name" fileName:@"publish"] forState:UIControlStateNormal];
         voteBtn.titleLabel.font = kRegularFont(12);
           [voteBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [voteBtn addTarget:self action:@selector(voteBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:voteBtn];
        
        statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        statusBtn.frame = CGRectZero;
        [statusBtn setImage:[AppContext getImageForKey:@"publisher_status"] forState:UIControlStateNormal];
         [statusBtn setTitle:[AppContext getStringForKey:@"image_status" fileName:@"publish"] forState:UIControlStateNormal];
         statusBtn.titleLabel.font = kRegularFont(12);
         [statusBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [statusBtn addTarget:self action:@selector(statusBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:statusBtn];
        
        emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        emojiBtn.frame = CGRectZero;
        [emojiBtn setImage:[AppContext getImageForKey:@"publisher_emoji"] forState:UIControlStateNormal];
        //        [emojiBtn setImage:[AppContext getImageForKey:@"publish_emoji_h"] forState:UIControlStateHighlighted];
        [emojiBtn addTarget:self action:@selector(emojiBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:emojiBtn];
        
        
        contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contactBtn.frame = CGRectZero;
        [contactBtn setImage:[AppContext getImageForKey:@"publisher_inform"] forState:UIControlStateNormal];
        //        [contactBtn setImage:[AppContext getImageForKey:@"publish_about_h"] forState:UIControlStateHighlighted];
        [contactBtn addTarget:self action:@selector(contactBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contactBtn];

        linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        linkBtn.frame = CGRectZero;
        [linkBtn setImage:[AppContext getImageForKey:@"publisher_link"] forState:UIControlStateNormal];
        //        [linkBtn setImage:[AppContext getImageForKey:@"publish_link_h"] forState:UIControlStateHighlighted];
        [linkBtn addTarget:self action:@selector(linkBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:linkBtn];
        
        bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        bottomLine.backgroundColor = kUIColorFromRGB(0xEEEEEE);
        [self addSubview:bottomLine];
        

        [self changeInputStatus:NO];

        
//        locationView.hidden = NO;
//        voteBtn.hidden = NO;
    }
    return self;
}

-(void)locationBtnPressed
{
    [_delegate locationBtn];
}

-(void)locationDeleteBtnPressed
{
    _location = nil;
}



-(void)photoBtnPressed
{
    if ([_delegate respondsToSelector:@selector(albumBtn)])
    {
        [_delegate albumBtn];
    }
}

-(void)camareBtnPressed
{
    [_delegate camareBtn];
}

-(void)videoBtnPressed
{
    if ([_delegate respondsToSelector:@selector(videoBtn)])
    {
        [_delegate videoBtn];
    }
}

-(void)voteBtnPressed
{
    [_delegate voteBtn];
}

-(void)statusBtnPressed
{
    [_delegate statusBtnPressed];
}

-(void)emojiBtnPressed
{
    [_delegate emojiBtn];
}


-(void)contactBtnPressed
{
    [_delegate contactBtn];
}

-(void)linkBtnPressed
{
    [_delegate linkBtn];
}



//-(void)topicBtnPressed
//{
//    [_delegate topicBtn];
//}
//
////-(void)sendBtnPressed
//{
//    [_delegate sendBtn];
//}



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



-(void)changeCharNum:(NSInteger)num
{
    if (num == 0)
    {
        countLabel.text = @"";
        countLabel.textColor = charNumColorGrey;
    }
    
    if (num > 0 && num <= 275)
    {
        countLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
        countLabel.textColor = charNumColorGrey;
    }
    
    if (num > 275 && num <= 1000)
    {
        countLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
        countLabel.textColor = charNumColorOrange;
    }
    
    if (num > 1000)
    {
        {
            countLabel.text = [NSString stringWithFormat:@"-%ld",(long)(num-1000)];
            countLabel.textColor = charNumColorRed;
        }
    }
}

//-(BOOL)sendEnabled
//{
//    return sendBtn.enabled;
//}
//-(void)enableTopicBtn
//{
//    [topicBtn setImage:[AppContext getImageForKey:@"publish_topic"] forState:UIControlStateNormal];
//}
//
//-(void)disableTopicBtn
//{
//    [topicBtn setImage:[AppContext getImageForKey:@"publish_icon_unclick_topic"] forState:UIControlStateNormal];
//}

-(void)setLocation:(RDLocation *)location
{
    _location = location;
    
    [locationView changeLocvationName:_location.place];
}

-(void)enableAllBtn
{
    photoBtn.enabled = YES;
    camareBtn.enabled = YES;
    videoBtn.enabled = YES;
    voteBtn.enabled = YES;
    statusBtn.enabled = YES;
    contactBtn.enabled = YES;
    linkBtn.enabled = YES;
    
    [photoBtn setImage:[AppContext getImageForKey:@"publisher_image"] forState:UIControlStateNormal];
    [camareBtn setImage:[AppContext getImageForKey:@"publisher_inform_camera"] forState:UIControlStateNormal];
    [videoBtn setImage:[AppContext getImageForKey:@"publisher_video"] forState:UIControlStateNormal];
    [voteBtn setImage:[AppContext getImageForKey:@"publisher_poll"] forState:UIControlStateNormal];
    [statusBtn setImage:[AppContext getImageForKey:@"publisher_status"] forState:UIControlStateNormal];
    [contactBtn setImage:[AppContext getImageForKey:@"publisher_inform"] forState:UIControlStateNormal];
    [linkBtn setImage:[AppContext getImageForKey:@"publisher_link"] forState:UIControlStateNormal];
}


-(void)enablePhotoCamera
{
    photoBtn.enabled = YES;
    camareBtn.enabled = YES;
    videoBtn.enabled = NO;
    voteBtn.enabled = NO;
    statusBtn.enabled = NO;
    contactBtn.enabled = YES;
    linkBtn.enabled = YES;
    
    [videoBtn setImage:[AppContext getImageForKey:@"publisher_video_dis"] forState:UIControlStateNormal];
    [voteBtn setImage:[AppContext getImageForKey:@"publisher_poll_dis"] forState:UIControlStateNormal];
    [statusBtn setImage:[AppContext getImageForKey:@"publisher_status_dis"] forState:UIControlStateNormal];
}

-(void)enableVideo
{
    photoBtn.enabled = YES;
    camareBtn.enabled = NO;
    videoBtn.enabled = NO;
    voteBtn.enabled = NO;
    statusBtn.enabled = NO;
    contactBtn.enabled = YES;
    linkBtn.enabled = YES;
    
    [videoBtn setImage:[AppContext getImageForKey:@"publisher_video_dis"] forState:UIControlStateNormal];
    [camareBtn setImage:[AppContext getImageForKey:@"publisher_inform_camera_dis"] forState:UIControlStateNormal];
    [voteBtn setImage:[AppContext getImageForKey:@"publisher_poll_dis"] forState:UIControlStateNormal];
    [statusBtn setImage:[AppContext getImageForKey:@"publisher_status_dis"] forState:UIControlStateNormal];
}




-(void)enableALLBtnExceptVoteAndPhotoBtn
{
    photoBtn.enabled = NO;
    camareBtn.enabled = NO;
    videoBtn.enabled = NO;
    voteBtn.enabled = NO;
    statusBtn.enabled = NO;
    

    [photoBtn setImage:[AppContext getImageForKey:@"publisher_image_dis"] forState:UIControlStateNormal];
    [camareBtn setImage:[AppContext getImageForKey:@"publisher_inform_camera_dis"] forState:UIControlStateNormal];
    [videoBtn setImage:[AppContext getImageForKey:@"publisher_video_dis"] forState:UIControlStateNormal];
    [voteBtn setImage:[AppContext getImageForKey:@"publisher_poll_dis"] forState:UIControlStateNormal];
    [statusBtn setImage:[AppContext getImageForKey:@"publisher_status_dis"] forState:UIControlStateNormal];
    [contactBtn setImage:[AppContext getImageForKey:@"publisher_inform"] forState:UIControlStateNormal];
    [linkBtn setImage:[AppContext getImageForKey:@"publisher_link"] forState:UIControlStateNormal];
    

    contactBtn.enabled = YES;
    linkBtn.enabled = YES;
}

-(void)disableaAllBtnExceptEmojiBtn
{
    photoBtn.enabled = NO;
    camareBtn.enabled = NO;
    videoBtn.enabled = NO;
    voteBtn.enabled = NO;
    statusBtn.enabled = NO;
    contactBtn.enabled = NO;
    linkBtn.enabled = NO;
    
    [photoBtn setImage:[AppContext getImageForKey:@"publisher_image_dis"] forState:UIControlStateNormal];
    [camareBtn setImage:[AppContext getImageForKey:@"publisher_inform_camera_dis"] forState:UIControlStateNormal];
    [videoBtn setImage:[AppContext getImageForKey:@"publisher_video_dis"] forState:UIControlStateNormal];
    [voteBtn setImage:[AppContext getImageForKey:@"publisher_poll_dis"] forState:UIControlStateNormal];
    [statusBtn setImage:[AppContext getImageForKey:@"publisher_status_dis"] forState:UIControlStateNormal];
    [contactBtn setImage:[AppContext getImageForKey:@"publisher_inform_dis"] forState:UIControlStateNormal];
    [linkBtn setImage:[AppContext getImageForKey:@"publisher_link_dis"] forState:UIControlStateNormal];
  
    emojiBtn.enabled = YES;
}


-(void)changeInputStatus:(BOOL)flag //YES 是输入状态,NO是非输入状态
{
    if (flag){
        CGFloat btnWidth = kScreenWidth/8.0;
        self.height = 80;

        CGFloat btnHeight = 44;
        photoBtn.frame = CGRectMake(0, 36, btnWidth, btnHeight);
        camareBtn.frame = CGRectMake(photoBtn.right, 36, btnWidth, btnHeight);
        videoBtn.frame = CGRectMake(camareBtn.right, 36, btnWidth, btnHeight);
        voteBtn.frame = CGRectMake(videoBtn.right, 36, btnWidth, btnHeight);
        statusBtn.frame = CGRectMake(voteBtn.right, 36, btnWidth, btnHeight);
        
        emojiBtn.frame =  CGRectMake(statusBtn.right, 36, btnWidth, btnHeight);
        contactBtn.frame =  CGRectMake(emojiBtn.right, 36, btnWidth, btnHeight);
        linkBtn.frame =  CGRectMake(contactBtn.right, 36, btnWidth, btnHeight);
        bottomLine.frame =  CGRectMake(0, linkBtn.bottom - 1, kScreenWidth, 1);
        
        photoBtn.imageEdgeInsets = UIEdgeInsetsMake((btnHeight - 28)/2.0 - 2.5, (btnWidth - 28)/2.0, (btnHeight - 28)/2.0 + 2.5, (btnWidth - 28)/2.0);
        camareBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        videoBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        voteBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        statusBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        emojiBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        contactBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        linkBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
    
        [photoBtn setTitle:nil forState:UIControlStateNormal];
        [camareBtn setTitle:nil forState:UIControlStateNormal];
        [videoBtn setTitle:nil forState:UIControlStateNormal];
        [voteBtn setTitle:nil forState:UIControlStateNormal];
        [statusBtn setTitle:nil forState:UIControlStateNormal];
        
    }
    else{
        CGFloat btnWidth = (kScreenWidth - 2*12)/5.0;
        self.height = 110;

        CGFloat btnHeight = 78;
        
        photoBtn.frame = CGRectMake(12, 36, btnWidth, btnHeight);
        camareBtn.frame = CGRectMake(photoBtn.right, 36, btnWidth, btnHeight);
        videoBtn.frame = CGRectMake(camareBtn.right, 36, btnWidth, btnHeight);
        voteBtn.frame = CGRectMake(videoBtn.right, 36, btnWidth, btnHeight);
        statusBtn.frame = CGRectMake(voteBtn.right, 36, btnWidth, btnHeight);
        
        emojiBtn.frame = CGRectZero;
        contactBtn.frame = CGRectZero;
        linkBtn.frame = CGRectZero;
        bottomLine.frame = CGRectZero;
        
        
        photoBtn.imageEdgeInsets = UIEdgeInsetsMake(8, (btnWidth - 40)/2.0, 30, (btnWidth - 40)/2.0);
        photoBtn.titleEdgeInsets = UIEdgeInsetsMake(54, -40, 10, 0);
        
        camareBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        camareBtn.titleEdgeInsets = photoBtn.titleEdgeInsets;
        
        videoBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        videoBtn.titleEdgeInsets = photoBtn.titleEdgeInsets;
        
        voteBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        voteBtn.titleEdgeInsets = photoBtn.titleEdgeInsets;
        
        statusBtn.imageEdgeInsets = photoBtn.imageEdgeInsets;
        statusBtn.titleEdgeInsets = photoBtn.titleEdgeInsets;
        
        
        emojiBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        contactBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        linkBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        
        [photoBtn setTitle:[AppContext getStringForKey:@"short_cut_alumb_name" fileName:@"publish"] forState:UIControlStateNormal];
        [camareBtn setTitle:[AppContext getStringForKey:@"short_cut_snapshot_name" fileName:@"publish"] forState:UIControlStateNormal];
        [videoBtn setTitle:[AppContext getStringForKey:@"short_cut_video_name" fileName:@"publish"]forState:UIControlStateNormal];
        [voteBtn setTitle:[AppContext getStringForKey:@"short_cut_poll_name" fileName:@"publish"] forState:UIControlStateNormal];
        [statusBtn setTitle:[AppContext getStringForKey:@"image_status" fileName:@"publish"] forState:UIControlStateNormal];
        
    }

}


@end
