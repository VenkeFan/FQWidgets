//
//  WLAssetsManager.h
//  WeLike
//
//  Created by fan qi on 2018/4/4.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLAssetModel.h"

extern NSInteger const kMaxCheckedVideoLimit;
extern NSInteger const kMaxCheckedNumberLimit;

extern NSString * AssetsConfirmBtnTitle(NSInteger count, NSInteger max);

@interface WLAssetsManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy, readonly) NSArray<PHAssetCollection *> *allAlbums;
@property (nonatomic, copy, readonly) NSArray<WLAssetModel *> *assets;

@property (nonatomic, strong, readonly) PHAssetCollection *currentAlbum;

- (void)requestPhotoAuthAuthorizationWithFinished:(void(^)(BOOL granted))finished;
- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection;
- (WLAssetModel *)insertPHAssetToFirst:(PHAsset *)asset;

+ (void)saveVideoToCameraRollWithFilePath:(NSString *)filePath
                                 finished:(void(^)(PHAsset *asset))finished;

+ (void)saveImageToCameraRoll:(UIImage *)image
                     finished:(void(^)(PHAsset *asset))finished;

+ (void)saveImageToCustomAblum:(UIImage *)image finished:(void(^)(PHAsset *asset))finished;

@end
