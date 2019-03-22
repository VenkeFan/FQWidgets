//
//  WLMixedPlayerView.h
//  welike
//
//  Created by fan qi on 2018/6/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLAbstractPlayerView.h"
#import "WLTrackerPlayer.h"

#define kMarginalCacheValue         (10.0)

@class AVAsset, WLVideoPost, WLMixedPlayerView;

@protocol WLMixedPlayerViewProtocol <NSObject>

@property (nonatomic, weak) WLMixedPlayerView *mixedPlayerView;

- (void)mixedPlayerViewAutoPlay;
- (void)destroyMixedPlayerView;

@end

@protocol WLMixedPlayerViewDelegate <NSObject>

@optional
- (void)mixedPlayerViewOrientationDidChanged:(WLMixedPlayerView *)playerView;
- (void)mixedPlayerView:(WLMixedPlayerView *)playerView statusDidChanged:(WLPlayerViewStatus)status;

@end

@interface WLMixedPlayerView : UIView

- (void)setAsset:(AVAsset *)asset;

@property (nonatomic, strong, readonly) WLAbstractPlayerView *playerView;

@property (nonatomic, strong) WLVideoPost *videoModel;

@property (nonatomic, copy, readonly) NSString *urlString;
@property (nonatomic, copy, readonly) NSString *videoID;
@property (nonatomic, strong, readonly) AVAsset *asset;

@property (nonatomic, weak) id<WLMixedPlayerViewDelegate> delegate;

- (void)dismiss;

@end
