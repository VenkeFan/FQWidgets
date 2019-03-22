//
//  WLAVPlayerView.h
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WLAbstractPlayerView.h"

@interface WLAVPlayerView : WLAbstractPlayerView

- (instancetype)initWithURLString:(NSString *)urlString;
- (instancetype)initWithAsset:(AVAsset *)asset;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) UIImage *previewImage;

@end
