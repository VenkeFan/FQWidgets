//
//  WLAbstractPlayerView.m
//  welike
//
//  Created by fan qi on 2018/6/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAbstractPlayerView.h"
#import "AFNetworkManager.h"

@implementation WLAbstractPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _loop = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.operateView.frame = self.bounds;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.operateView];
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - Public

- (BOOL)checkNetworkReachable {
    if ([AFNetworkManager getInstance].reachabilityStatus == HLNetWorkStatusNotReachable) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"error_network_poor" fileName:@"error"]];
        return NO;
    }
    return YES;
}

#pragma mark - Setter

- (void)setWindowMode:(WLPlayerViewWindowMode)windowMode {
    _windowMode = windowMode;
    
    self.operateView.windowMode = windowMode;
}

- (void)setPlayerViewStatus:(WLPlayerViewStatus)playerViewStatus {
    _playerViewStatus = playerViewStatus;
    
    switch (playerViewStatus) {
        case WLPlayerViewStatus_Unknown:
            
            break;
        case WLPlayerViewStatus_ReadyToPlay:
            
            break;
        case WLPlayerViewStatus_Playing:
            
            break;
        case WLPlayerViewStatus_Paused:
            
            break;
        case WLPlayerViewStatus_CachingPaused:
            
            break;
        case WLPlayerViewStatus_Stopped:
            
            break;
        case WLPlayerViewStatus_Completed: {
            if (self.isLoop) {
                [self play];
            }
        }
            break;
        case WLPlayerViewStatus_Failed:
            
            break;
    }
    
    [self.operateView setPlayerViewStatus:playerViewStatus];
    
    if ([self.delegate respondsToSelector:@selector(playerView:statusDidChanged:)]) {
        [self.delegate playerView:self statusDidChanged:playerViewStatus];
    }
}

#pragma mark - Getter

- (WLPlayerOperateView *)operateView {
    if (!_operateView) {
        WLPlayerOperateView *view = [[WLPlayerOperateView alloc] init];
        view.playerView = self;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _operateView = view;
    }
    return _operateView;
}

@end
