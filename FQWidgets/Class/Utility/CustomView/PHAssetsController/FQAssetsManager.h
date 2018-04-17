//
//  FQAssetsManager.h
//  WeLike
//
//  Created by fan qi on 2018/4/4.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FQAssetModel.h"

@interface FQAssetsManager : NSObject

@property (nonatomic, copy, readonly) NSArray<PHAssetCollection *> *allAlbums;
@property (nonatomic, copy, readonly) NSArray<FQAssetModel *> *assets;

@property (nonatomic, strong, readonly) PHAssetCollection *currentAlbum;

- (void)requestPhotoAuthAuthorizationWithFinished:(void(^)(BOOL granted))finished;
- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection;

@end
