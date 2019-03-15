//
//  FQHtmlAnimatedView.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/11.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlAnimatedView.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+WebCache.h"
#import "FQHtmlTextAttachment.h"

@interface FQHtmlAnimatedView ()

@property (nonatomic, strong) FLAnimatedImageView *animatedImgView;
@property (nonatomic, strong) CALayer *signLayer;
@property (nonatomic, strong) CATextLayer *txtLayer;

@end

@implementation FQHtmlAnimatedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor cyanColor];
        
        _animatedImgView = [[FLAnimatedImageView alloc] initWithFrame:frame];
        _animatedImgView.image = [FQHtmlTextAttachment placeholder];;
        [self addSubview:_animatedImgView];
        
        _signLayer = [CALayer layer];
        _signLayer.frame = CGRectMake(0, 0, 40, 20);
        _signLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6].CGColor;
        _signLayer.cornerRadius = 4.0;
        [self.layer addSublayer:_signLayer];
        
        _txtLayer = [CATextLayer layer];
        _txtLayer.frame = CGRectMake(0, 0, 40, 15);
        _txtLayer.backgroundColor = [UIColor clearColor].CGColor;
        _txtLayer.contentsScale = kScreenScale;
        _txtLayer.alignmentMode = kCAAlignmentCenter;
        _txtLayer.truncationMode = kCATruncationEnd;
        _txtLayer.string = @"GIF";
        _txtLayer.foregroundColor = [UIColor whiteColor].CGColor;
        
        UIFont *font = kRegularFont(12.0);
        CGFontRef cgFont = CGFontCreateWithFontName((__bridge CFStringRef)font.fontName);
        _txtLayer.font = cgFont;
        _txtLayer.fontSize = font.pointSize;
        CGFontRelease(cgFont);
        
        [_signLayer addSublayer:_txtLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _animatedImgView.frame = self.bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _signLayer.position = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_signLayer.frame) * 0.5 - 12, CGRectGetHeight(self.frame) - CGRectGetHeight(_signLayer.frame) * 0.5 - 12);
    _txtLayer.position = CGPointMake(CGRectGetWidth(_signLayer.bounds) * 0.5, CGRectGetHeight(_signLayer.bounds) * 0.5);
    [CATransaction commit];
}

- (void)dealloc {
    NSLog(@"FQHtmlAnimatedView dealloc *************");
}

- (void)setAnimatedImage:(FLAnimatedImage *)animatedImage {
    _animatedImage = animatedImage;
    
    if (animatedImage) {
        self.animatedImgView.image = nil;
        self.animatedImgView.animatedImage = animatedImage;
    } else {
        self.animatedImgView.image = [FQHtmlTextAttachment placeholder];
        self.animatedImgView.animatedImage = nil;
    }
}

@end

@implementation FQHtmlAnimatedViewManager

- (FQHtmlAnimatedView *)animatedView {
    if (!_animatedView) {
        _animatedView = [FQHtmlAnimatedView new];
        _animatedView.frame = self.frame;
        _animatedView.animatedImage = self.animatedImage;
    }
    return _animatedView;
}

@end
