//
//  FQVideoComposition.h
//  FQWidgets
//
//  Created by fan qi on 2018/8/29.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAsset;

@interface FQVideoComposition : NSObject

- (void)composeVideo:(AVAsset *)firstVideoAsset secondVideoAsset:(AVAsset *)secondVideoAsset;
- (void)composeVideo:(AVAsset *)videoAsset audio:(AVAsset *)audioAsset;
- (void)composeVideo:(AVAsset *)videoAsset image:(UIImage *)image;
- (void)composeVideo:(AVAsset *)videoAsset gifPath:(NSString *)gifPath;
- (void)composeAudio:(AVAsset *)firstAudioAsset secondAudioAsset:(AVAsset *)secondAudioAsset;

@end
