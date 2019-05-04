//
//  FQAssetReader.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/19.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class FQAssetReader;

@protocol FQAssetReaderDelegate <NSObject>

- (void)assetReader:(FQAssetReader *)reader didReadingBuffer:(CMSampleBufferRef)buffer;
- (void)assetReaderDidCompleted:(FQAssetReader *)reader;

@end

@interface FQAssetReader : NSObject

@property (nonatomic, weak) id<FQAssetReaderDelegate> delegate;
- (void)startReadingWithAsset:(AVAsset *)asset;

@end
