//
//  WLVideoThumbView.m
//  welike
//
//  Created by gyb on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVideoThumbView.h"
#import <Photos/Photos.h>
#import "WLImageHelper.h"

@implementation WLVideoThumbView

-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        videoThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,frame.size.width, frame.size.height)];
        videoThumb.contentMode = UIViewContentModeScaleAspectFill;
        videoThumb.clipsToBounds = YES;
        videoThumb.userInteractionEnabled = YES;
        [self addSubview:videoThumb];
       
        
        videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        videoBtn.frame = CGRectMake(0, 0, videoThumb.width, videoThumb.height);
        [videoBtn addTarget:self action:@selector(videoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [videoThumb addSubview:videoBtn];
       
      
        
        UIImage *videoFlagImage = [AppContext getImageForKey:@"publish_video_thumb"];
        videoFlag = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - videoFlagImage.size.width)/2.0, (frame.size.height - videoFlagImage.size.height)/2.0, videoFlagImage.size.width, videoFlagImage.size.height)];
        videoFlag.image = videoFlagImage;
        [videoThumb addSubview:videoFlag];
       
        
        
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(videoBtn.width - 30, 0, 30, 30);
        [closeBtn setImage: [AppContext getImageForKey:@"publish_gridPic_delete"] forState:UIControlStateNormal];
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(closeBtn.imageEdgeInsets.top-3, closeBtn.imageEdgeInsets.left + 3, closeBtn.imageEdgeInsets.bottom+3, closeBtn.imageEdgeInsets.right-3);
        [closeBtn addTarget:self action:@selector(closeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        closeBtn.showsTouchWhenHighlighted = YES;
        [videoThumb addSubview:closeBtn];
       
        
        durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(videoThumb.width - 105, videoThumb.height - 14 - 5, 100, 14)];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.numberOfLines = 1;
        durationLabel.font = kRegularFont(12);
        durationLabel.textAlignment = NSTextAlignmentRight;
        [videoThumb addSubview:durationLabel];
        
        videoThumb.hidden = YES;
        videoBtn.hidden = YES;
        videoFlag.hidden =  YES;
        closeBtn.hidden = YES;
        durationLabel.hidden =  YES;
    }
    return self;
}

-(void)setVideoAsset:(PHAsset *)videoAsset
{
    if (videoAsset)
    {
        videoThumb.hidden = NO;
        videoBtn.hidden = NO;
        videoFlag.hidden =  NO;
        closeBtn.hidden = NO;
        durationLabel.hidden =  NO;
        
        
//        self.height = 186;
//        videoBtn.height = 186;
//        videoThumb.height = 186;
  
        
        NSInteger min = videoAsset.duration/60;
        NSInteger second = (NSInteger)videoAsset.duration % 60;
       
        NSString *minStr;
        if (min >= 10)
        {
            minStr = [NSString stringWithFormat:@"%ld", (long)min];
        }
        else
        {
            minStr = [NSString stringWithFormat:@"0%ld", (long)min];
        }
        
        NSString *secStr;
        if (second >= 10)
        {
            secStr = [NSString stringWithFormat:@"%ld", (long)second];
        }
        else
        {
            secStr = [NSString stringWithFormat:@"0%ld", (long)second];
        }
        
        durationLabel.text = [NSString stringWithFormat:@"%@:%@ ",minStr,secStr];
        
        
        
        [WLImageHelper imageFromAsset:videoAsset size:CGSizeMake(videoAsset.pixelWidth, videoAsset.pixelHeight) result:^(UIImage *image) {
            
            self->videoThumb.image = image;
            
        }];
    }
    else
    {
        
        videoThumb.hidden = YES;
        videoBtn.hidden = YES;
        videoFlag.hidden =  YES;
        closeBtn.hidden = YES;
        durationLabel.hidden =  YES;
        videoThumb.image = nil;
    }
}


-(void)videoBtnPressed
{
    if ([self playSelectVideo])
    {
        self.playSelectVideo();
    }
}

-(void)closeBtnPressed
{
  

    videoThumb.hidden = YES;
    videoBtn.hidden = YES;
    videoFlag.hidden =  YES;
    closeBtn.hidden = YES;
    durationLabel.hidden =  YES;
    videoThumb.image = nil;
    
    if ([self closeBlock])
    {
        self.closeBlock();
    }
}

@end
