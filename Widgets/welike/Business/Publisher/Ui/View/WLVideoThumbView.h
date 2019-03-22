//
//  WLVideoThumbView.h
//  welike
//
//  Created by gyb on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@interface WLVideoThumbView : UIView
{
    UIButton *videoBtn;
    UIButton *closeBtn;
    UIImageView *videoFlag;
    UILabel *durationLabel;
    UIImageView *videoThumb;
}

@property (strong,nonatomic) PHAsset *videoAsset;

@property (nonatomic,copy) void(^closeBlock)(void);
@property (nonatomic,copy) void(^playSelectVideo)(void);


@end
