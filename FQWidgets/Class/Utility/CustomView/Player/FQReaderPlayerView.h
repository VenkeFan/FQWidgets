//
//  FQReaderPlayerView.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/19.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FQReaderPlayerView : UIView

- (instancetype)initWithAsset:(AVAsset *)asset;

- (void)playWithAsset:(AVAsset *)asset;
- (void)play;

@end
