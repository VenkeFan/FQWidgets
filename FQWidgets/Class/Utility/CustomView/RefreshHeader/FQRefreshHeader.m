//
//  FQRefreshHeader.m
//  WeLike
//
//  Created by fan qi on 2018/3/29.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQRefreshHeader.h"
#import "FQGradientCircleLayer.h"

NSString * const FQRefreshHeaderTitle[] = {
    [MJRefreshStateIdle]        = @"Pull down to refresh",
    [MJRefreshStatePulling]     = @"Release to refresh",
    [MJRefreshStateRefreshing]  = @"Refreshing",
    [MJRefreshStateWillRefresh] = @"",
    [MJRefreshStateNoMoreData]  = @""
};

@interface FQRefreshHeader ()

//@property (nonatomic, weak) UILabel *titleLab;
//@property (nonatomic, weak) UIView *loadingView;
//@property (nonatomic, weak) UIImageView *arrowView;

@property (nonatomic, weak) FQGradientCircleLayer *circleLayer;

@end

@implementation FQRefreshHeader

#pragma mark - Override

- (void)prepare {
    [super prepare];
    
    self.mj_h = 50;
    self.mj_w = kScreenWidth;
}

- (void)placeSubviews {
    [super placeSubviews];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
//    NSLog(@"%@", change[@"new"]);
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change {
    [super scrollViewPanStateDidChange:change];
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle: {
            [self.circleLayer stopAnimating];
            self.circleLayer.strokeEnd = 0.0;
        }
            break;
        case MJRefreshStatePulling: {
            [self.circleLayer stopAnimating];
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.circleLayer.strokeEnd = 1.0;
            }];
        }
            break;
        case MJRefreshStateRefreshing: {
            [UIView animateWithDuration:MJRefreshFastAnimationDuration
                             animations:^{
                                 self.circleLayer.strokeEnd = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 [self.circleLayer beginAnimating];
                             }];
        }
            break;
        default:
            break;
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    
    self.circleLayer.strokeEnd = pullingPercent;
}

#pragma mark - Getter

- (FQGradientCircleLayer *)circleLayer {
    if (!_circleLayer) {
        FQGradientCircleLayer *layer = [FQGradientCircleLayer layer];
        layer.frame = CGRectMake(0, 0, kSizeScale(30), kSizeScale(30));
        layer.position = self.layer.position;
        [self.layer addSublayer:layer];
        _circleLayer = layer;
    }
    return _circleLayer;
}

@end
