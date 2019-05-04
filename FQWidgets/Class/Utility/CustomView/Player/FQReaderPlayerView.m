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

@interface FQReaderPlayerView () <FQAssetReaderDelegate, FQPlayerOperateViewDelegate> {
    AVAsset *_asset;
    
    FQAssetReader *_assetReader;
    
    GLKView *_glkView;
    CIContext *_ciContext;
}

@property (nonatomic, strong) FQPlayerOperateView *operateView;

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
        
        [self addSubview:self.operateView];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _glkView.frame = self.bounds;
    _operateView.frame = self.bounds;
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

- (void)pause {
    
}

- (void)stop {
    
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

#pragma mark - FQPlayerOperateViewDelegate

- (void)playerOperateViewDidClickedPlay:(FQPlayerOperateView *)operateView {
    if (self.playerViewStatus != FQPlayerViewStatus_Playing) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)playerOperateViewDidClickedStop:(FQPlayerOperateView *)operateView {
    [self stop];
}

- (void)playerOperateView:(FQPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue {
    
}

#pragma mark - Setter

- (void)setPlayerViewStatus:(FQPlayerViewStatus)playerViewStatus {
    if (playerViewStatus == _playerViewStatus) {
        return;
    }
    _playerViewStatus = playerViewStatus;
    
    [self.operateView setPlayerViewStatus:playerViewStatus];
    
    switch (playerViewStatus) {
        case FQPlayerViewStatus_Unknown:
            
            break;
        case FQPlayerViewStatus_ReadyToPlay:
            
            break;
        case FQPlayerViewStatus_Playing:
            
            break;
        case FQPlayerViewStatus_Paused:
            
            break;
        case FQPlayerViewStatus_CachingPaused:
            
            break;
        case FQPlayerViewStatus_Stopped:
            
            break;
        case FQPlayerViewStatus_Completed:
            
            break;
        case FQPlayerViewStatus_Failed:
            
            break;
    }
}

#pragma mark - Getter

- (FQPlayerOperateView *)operateView {
    if (!_operateView) {
        FQPlayerOperateView *view = [[FQPlayerOperateView alloc] init];
        view.delegate = self;
        _operateView = view;
    }
    return _operateView;
}

@end
