//
//  FQAssetsManager.m
//  WeLike
//
//  Created by fan qi on 2018/4/4.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FQAssetsManager ()

@end

@implementation FQAssetsManager

- (instancetype)init {
    if (self = [super init]) {
        [self fetchAllAlbums];
        [self fetchAllPhotos];
    }
    return self;
}

#pragma mark - Public

- (void)requestPhotoAuthAuthorizationWithFinished:(void (^)(BOOL granted))finished {
    if (kiOS9Later) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self fetchAllAlbums];
                    [self fetchAllPhotos];
                }
                
                if (finished) {
                    finished(status == PHAuthorizationStatusAuthorized);
                }
            }];
        } else if (authStatus == PHAuthorizationStatusAuthorized) {
            [self fetchAllAlbums];
            [self fetchAllPhotos];
            
            if (finished) {
                finished(YES);
            }
        } else {
            if (finished) {
                finished(NO);
            }
        }
    }
}

- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    
    NSMutableArray<FQAssetModel *> *assetModels = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        if (asset.mediaType == PHAssetMediaTypeImage || asset.mediaType == PHAssetMediaTypeVideo) {
            FQAssetModel *model = [[FQAssetModel alloc] initWithType:FQAssetModelType_Photo asset:asset];
            model.type = (FQAssetModelType)asset.mediaType;
            model.asset = asset;
            [assetModels addObject:model];
        }
    }
    _assets = assetModels;
    
}

#pragma mark - Private

- (void)fetchAllAlbums {
    NSMutableArray<PHAssetCollection *> *albums = [NSMutableArray array];
    
    PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                               subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                                               options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumAllHidden && obj.assetCollectionSubtype!= 1000000201) {
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
            if (assets.count > 0) {
                [albums addObject:obj];
            }
        }
    }];
    
//    PHFetchResult<PHCollection *> *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult<PHAssetCollection *> *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                              subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                                              options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
        if (assets.count > 0) {
            [albums addObject:obj];
        }
    }];
    
    _allAlbums = albums;
}

- (void)fetchAllPhotos {
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                        subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                        options:nil].firstObject;
    [self fetchAssetsWithAssetCollection:cameraRoll];
}

@end
