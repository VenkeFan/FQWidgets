//
//  FQAssetModel.h
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, FQAssetModelType) {
    FQAssetModelType_Camera = 0,
    FQAssetModelType_Photo  = 1,
    FQAssetModelType_Video  = 2
};

@interface FQAssetModel : NSObject <NSCopying>

- (instancetype)initWithType:(FQAssetModelType)type asset:(PHAsset *)asset;

@property (nonatomic, assign) FQAssetModelType type;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign, getter=isChecked) BOOL checked;
@property (nonatomic, assign) NSInteger checkedIndex;
@property (nonatomic, assign) CGFloat quality;      ///< 资源质量大小，以M为单位

@end
