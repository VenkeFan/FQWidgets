//
//  WLRotatableView.m
//  welike
//
//  Created by fan qi on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRotatableView.h"

@implementation WLRotatableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _rotatable = YES;
        _viewWidth = [UIScreen mainScreen].bounds.size.width;
        _viewHeight = [UIScreen mainScreen].bounds.size.height;
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor blackColor];
        [self addSubview:_contentView];
        
        [self addNotifications];
    }
    return self;
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (!newWindow) {
        _rotatable = NO;
    } else {
        _rotatable = YES;
    }
}

#pragma mark - DeviceOrientation

- (void)addNotifications {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChanged:(NSNotification *)notification {
    if (self.isRotatable) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        [self setOrientation:orientation];
    }
}

- (void)setOrientation:(UIDeviceOrientation)orientation {
    _orientation = orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.contentView.transform = CGAffineTransformMakeRotation(0);
                self.contentView.bounds = CGRectMake(0, 0, self->_viewWidth, self->_viewHeight);
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.contentView.bounds = CGRectMake(0, 0, self->_viewHeight, self->_viewWidth);
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.contentView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.contentView.bounds = CGRectMake(0, 0, self->_viewHeight, self->_viewWidth);
            }];
        }
            break;
        default:
            break;
    }
}

@end
