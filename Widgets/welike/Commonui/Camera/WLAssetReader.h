//
//  WLAssetReader.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/19.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class WLAssetReader;

@protocol WLAssetReaderDelegate <NSObject>

- (void)assetReader:(WLAssetReader *)reader didReadingBuffer:(CMSampleBufferRef)buffer;
- (void)assetReaderDidCompleted:(WLAssetReader *)reader;

@end

@interface WLAssetReader : NSObject

@property (nonatomic, weak) id<WLAssetReaderDelegate> delegate;
- (void)startReadingWithAsset:(AVAsset *)asset;

@end
