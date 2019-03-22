//
//  WLMixedPlayerViewManager.m
//  welike
//
//  Created by fan qi on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMixedPlayerViewManager.h"
#import "WLMixedPlayerView.h"

@implementation WLMixedPlayerViewManager

+ (instancetype)instance {
    static WLMixedPlayerViewManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [WLMixedPlayerViewManager instance];
}

- (WLMixedPlayerView *)generateMixedPlayerView {
    [self destroyMixedPlayerView];
    
    _mixedPlayerView = [[WLMixedPlayerView alloc] init];
    return _mixedPlayerView;
}

- (void)destroyMixedPlayerView {
    if (_mixedPlayerView) {
        _mixedPlayerView.playerView.operateView.cacheProgress = 0.0;
        [_mixedPlayerView.playerView pause];
        [_mixedPlayerView removeFromSuperview];
        _mixedPlayerView = nil;
    }
}

@end
