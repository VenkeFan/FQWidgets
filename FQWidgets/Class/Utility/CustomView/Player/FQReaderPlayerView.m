//
//  FQReaderPlayerView.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/19.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQReaderPlayerView.h"
#import <GLKit/GLKit.h>
#import "FQAssetReader.h"

@interface FQReaderPlayerView () <FQAssetReaderDelegate> {
    AVAsset *_asset;
    
    FQAssetReader *_assetReader;
    
    GLKView *_glkView;
    CIContext *_ciContext;
}

@end

@implementation FQReaderPlayerView

#pragma mark - LifeCycle

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [self initWithFrame:CGRectZero]) {
        _asset = asset;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeOpenGL]; 
    }
    return self;
}

- (void)initializeOpenGL {
    EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glContext];
    
    _glkView = [[GLKView alloc] initWithFrame:self.bounds context:glContext];
    _glkView.contentMode = UIViewContentModeScaleAspectFit;
    _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [self addSubview:_glkView];
    
    _ciContext = [CIContext contextWithEAGLContext:glContext];
}

#pragma mark - Public

- (void)playWithAsset:(AVAsset *)asset {
    _asset = asset;
    [self play];
}

- (void)play {
    if (!_asset) {
        return;
    }
    
    if (!_assetReader) {
        _assetReader = [[FQAssetReader alloc] init];
        _assetReader.delegate = self;
    }
    [_assetReader startReadingWithAsset:_asset];
}

#pragma mark - FQAssetReaderDelegate

- (void)assetReader:(FQAssetReader *)reader didReadingBuffer:(CMSampleBufferRef)buffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, buffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:(__bridge NSDictionary *)attachments];
//    ciImage = [ciImage imageByApplyingTransform:[ciImage imageTransformForOrientation:6]];

    CGFloat screenScale = [[UIScreen mainScreen] scale];
    [_ciContext drawImage:ciImage inRect:CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(screenScale, screenScale)) fromRect:ciImage.extent];

    [_glkView display];
}

- (void)assetReaderDidCompleted:(FQAssetReader *)reader {
    
}

@end
