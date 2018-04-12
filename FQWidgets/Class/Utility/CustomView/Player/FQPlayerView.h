//
//  FQPlayerView.h
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FQPlayerOperateView.h"

@class FQPlayerView;

@protocol FQPlayerViewDelegate <NSObject>

- (void)playerView:(FQPlayerView *)playerView statusDidChanged:(FQPlayerViewStatus)status;

@end

@interface FQPlayerView : UIView

- (instancetype)initWithURLString:(NSString *)urlString;
- (instancetype)initWithAsset:(AVAsset *)asset;

- (void)play;
- (void)pause;
- (void)stop;

@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) FQPlayerViewStatus playerViewStatus;
@property (nonatomic, weak) id<FQPlayerViewDelegate> delegate;

@end
