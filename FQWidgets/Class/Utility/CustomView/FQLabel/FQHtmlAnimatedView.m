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
        
        UIImage *placeholder = [FQHtmlTextAttachment placeholder];
        
        _animatedImgView = [[FLAnimatedImageView alloc] init];
        if (frame.size.width > 0 && frame.size.height > 0) {
            _animatedImgView.frame = frame;
        } else {
            _animatedImgView.frame = CGRectMake(0, 0, placeholder.size.width, placeholder.size.height);
            self.frame = _animatedImgView.frame;
        }
        _animatedImgView.image = placeholder;
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
        
        NSLog(@"FQHtmlAnimatedView initialize *************");
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _animatedImgView.frame = self.bounds;
    _signLayer.position = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_signLayer.frame) * 0.5 - 12, CGRectGetHeight(self.frame) - CGRectGetHeight(_signLayer.frame) * 0.5 - 12);
    _txtLayer.position = CGPointMake(CGRectGetWidth(_signLayer.bounds) * 0.5, CGRectGetHeight(_signLayer.bounds) * 0.5);
}

- (void)dealloc {
    NSLog(@"FQHtmlAnimatedView dealloc *************");
}

- (void)setAnimatedImage:(FLAnimatedImage *)animatedImage {
    _animatedImage = animatedImage;
    
    if (animatedImage) {
        self.animatedImgView.image = nil;
        self.animatedImgView.animatedImage = animatedImage;
        
        CGRect frame = self.frame;
        frame.size = animatedImage.size;
        self.frame = frame;
    } else {
        UIImage *placeholder = [FQHtmlTextAttachment placeholder];
        
        self.animatedImgView.image = placeholder;
        self.animatedImgView.animatedImage = nil;
        
        CGRect frame = self.frame;
        frame.size = placeholder.size;
        self.frame = frame;
    }
}

@end
