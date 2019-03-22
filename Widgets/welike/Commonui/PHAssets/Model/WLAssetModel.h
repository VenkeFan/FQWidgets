//
//  WLAssetModel.h
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, WLAssetModelType) {
    WLAssetModelType_Camera = 0,
    WLAssetModelType_Photo  = 1,
    WLAssetModelType_Video  = 2
};

@interface WLAssetModel : NSObject <NSCopying>

- (instancetype)initWithType:(WLAssetModelType)type asset:(PHAsset *)asset;
+ (instancetype)modelWithImage:(UIImage *)image;

@property (nonatomic, assign) WLAssetModelType type;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter=isChecked) BOOL checked;
@property (nonatomic, assign) NSInteger checkedIndex;
@property (nonatomic, assign) CGFloat quality;      ///< 资源质量大小，以M为单位
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isGif;
@property (nonatomic, assign) BOOL isCloud;
@property (nonatomic, assign) BOOL hasSyncCloud;

@end
