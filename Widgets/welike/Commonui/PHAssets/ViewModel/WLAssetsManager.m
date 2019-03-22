//
//  WLAssetsManager.m
//  WeLike
//
//  Created by fan qi on 2018/4/4.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAssetsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WLAuthorizationHelper.h"

NSInteger const kMaxCheckedVideoLimit = 1;
NSInteger const kMaxCheckedNumberLimit = 9;

NSString * AssetsConfirmBtnTitle(NSInteger count, NSInteger max) {
    if (count <= 0) {
        return [AppContext getStringForKey:@"regist_next_btn" fileName:@"register"];
    }
    
    return [NSString stringWithFormat:@"%@ (%ld/%ld)", [AppContext getStringForKey:@"regist_next_btn" fileName:@"register"], (long)count, (long)max];
}

@interface WLAssetsManager ()

@end

@implementation WLAssetsManager

+ (instancetype)sharedInstance {
    static WLAssetsManager *_manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init];
    });
    
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [WLAssetsManager sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        [self fetchAllAlbums];
        [self fetchAllPhotos];
    }
    return self;
}

#pragma mark - Public

- (void)requestPhotoAuthAuthorizationWithFinished:(void (^)(BOOL granted))finished {
    [WLAuthorizationHelper requestPhotoAuthorizationWithFinished:^(BOOL granted) {
        if (granted) {
            [self fetchAllAlbums];
            [self fetchAllPhotos];
        }
        
        if (finished) {
            finished(granted);
        }
    }];
}

- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    
    NSMutableArray<WLAssetModel *> *assetModels = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        if (asset.mediaType == PHAssetMediaTypeImage || asset.mediaType == PHAssetMediaTypeVideo) {
            WLAssetModel *model = [[WLAssetModel alloc] initWithType:(WLAssetModelType)asset.mediaType asset:asset];
            model.asset = asset;
            [assetModels addObject:model];
        }
    }
    _assets = assetModels;
    
}

- (WLAssetModel *)insertPHAssetToFirst:(PHAsset *)asset {
    if (asset.mediaType == PHAssetMediaTypeImage || asset.mediaType == PHAssetMediaTypeVideo) {
        WLAssetModel *model = [[WLAssetModel alloc] initWithType:(WLAssetModelType)asset.mediaType asset:asset];
        model.asset = asset;
        
        NSMutableArray<WLAssetModel *> *assetModels = [NSMutableArray array];
        [assetModels addObject:model];
        [assetModels addObjectsFromArray:_assets];
        
        _assets = assetModels;
        
        return model;
    }
    
    return nil;
}

+ (void)saveVideoToCameraRollWithFilePath:(NSString *)filePath
                                 finished:(void (^)(PHAsset *))finished {
    if (!filePath) {
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) {
                return;
            }
            
            __block NSString *assetIdentifier = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypeVideo fileURL:[NSURL fileURLWithPath:filePath] options:nil];
                
                assetIdentifier = request.placeholderForCreatedAsset.localIdentifier;
                
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if (error) {
                    return;
                }
                if (!assetIdentifier) {
                    return;
                }
                
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil].firstObject;
                if (finished) {
                    finished(asset);
                }
                
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc] init];
        [lab writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:filePath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        return;
                                    }
                                    
                                    if (!assetURL) {
                                        return;
                                    }
                                    
                                    PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil].firstObject;
                                    if (finished) {
                                        finished(asset);
                                    }
                                }];
    }
}

+ (void)saveImageToCameraRoll:(UIImage *)image finished:(void (^)(PHAsset *))finished {
    if (!image) {
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) {
                return;
            }
            
            __block NSString *assetIdentifier = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypePhoto data:UIImageJPEGRepresentation(image, 1.0) options:nil];
                
                assetIdentifier = request.placeholderForCreatedAsset.localIdentifier;
                
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if (error) {
                    return;
                }
                if (!assetIdentifier) {
                    return;
                }
                
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil].firstObject;
                if (finished) {
                    finished(asset);
                }
                
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc] init];
        [lab writeImageToSavedPhotosAlbum:image.CGImage
                              orientation:(ALAssetOrientation)image.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (error) {
                                  return;
                              }
                              
                              if (!assetURL) {
                                  return;
                              }
                              
                              PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil].firstObject;
                              if (finished) {
                                  finished(asset);
                              }
                          }];
    }
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

//创建专有相册,并保存
+(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo
{
    //1 获取以 APP 的名称
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"thumb fail");
      
        return nil;
    }else{
         NSLog(@"thumb suc");
        //[SVProgressHUD showSuccessWithStatus:@"创建成功"];
        //通过 ID 获取创建完成的相册 -- 是一个数组
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
}

/**将图片保存到自定义相册中*/
+(void)saveImageToCustomAblum:(UIImage *)image finished:(void(^)(PHAsset *asset))finished
{
    //1 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [self syncSaveImageWithPhotos:image];
    if (assets == nil)
    {
          NSLog(@"save fail");
        //[SVProgressHUD showErrorWithStatus:@"保存失败"];
        return;
    }
    
    //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
    if (assetCollection == nil) {
       // [SVProgressHUD showErrorWithStatus:@"相册创建失败"];
         NSLog(@"create fail");
        return;
    }
    
    
    //3 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
        if (finished) {
            finished(assets.firstObject);
        }
    } error:&error];
    
    
    if (error) {
      NSLog(@"save fail");
        return;
    }
     NSLog(@"save suc");
}

//异步保存图片
-(void)asyncSaveImageWithPhotos:(UIImage *)image
{
    //1 必须在 block 中调用
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //2 异步执行保存图片操作
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //3 保存结束后，回调
        if (error) {
            //            [SVProgressHUD showErrorWithStatus:@"保存失败"];
            NSLog(@"save fail");
        }else
            //            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            NSLog(@"save suc");
    }];
}

+(PHFetchResult<PHAsset *> *)syncSaveImageWithPhotos:(UIImage *)image
{
    //--1 创建 ID 这个参数可以获取到图片保存后的 asset对象
    __block NSString *createdAssetID = nil;
    
    //--2 保存图片
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    //--3 如果失败，则返回空
    if (error) {
        return nil;
    }
    
    //--4 成功后，返回对象
    //获取保存到系统相册成功后的 asset 对象集合，并返回
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
    
}

@end
