//
//  FQZoomScaleView.m
//  WeLike
//
//  Created by fan qi on 2018/4/9.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQZoomScaleView.h"

@interface FQZoomScaleView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *contentView;

@end

@implementation FQZoomScaleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.contentOffset = CGPointZero;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
        self.alwaysBounceVertical = NO;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.zoomScale = 1.0;
    }
    return self;
}

#pragma mark - Public

- (void)addSubview:(UIView *)view {
    [self.contentView addSubview:view];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.contentView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                          scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Event

- (void)selfOnDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat maxZoomScale = self.maximumZoomScale;
        CGPoint point = [gesture locationInView:self.contentView];
        
        CGFloat newWidth = self.frame.size.width / maxZoomScale;
        CGFloat newHeight = self.frame.size.height / maxZoomScale;
        
        CGFloat newX = point.x - newWidth / 2;
        CGFloat newY = point.y - newHeight / 2;
        
        [self zoomToRect:CGRectMake(newX, newY, newWidth, newHeight) animated:YES];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        [self insertSubview:view atIndex:0];
        _contentView = view;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [view addGestureRecognizer:doubleTap];
    }
    return _contentView;
}

@end
