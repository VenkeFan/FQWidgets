//
//  WLAssetModel.m
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAssetModel.h"

@implementation WLAssetModel

#pragma mark - LifeCycle

- (instancetype)initWithType:(WLAssetModelType)type asset:(PHAsset *)asset {
    if (self = [super init]) {
        _type = type;
        _asset = asset;
        _checked = NO;
        _checkedIndex = -1;
        _quality = 0;
        _index = 0;
        _isCloud = NO;
        _hasSyncCloud = NO;
    }
    return self;
}

+ (instancetype)modelWithImage:(UIImage *)image {
    WLAssetModel *model = [[WLAssetModel alloc] initWithType:WLAssetModelType_Photo asset:nil];
    model.image = image;
    return model;
}

- (id)copyWithZone:(NSZone *)zone {
    WLAssetModel *copyModel = [[[self class] allocWithZone:zone] initWithType:_type asset:_asset];
    copyModel.checked = _checked;
    copyModel.checkedIndex = _checkedIndex;
    copyModel.quality = _quality;
    copyModel.image = _image;
    copyModel.index = _index;
    return copyModel;
}

#pragma mark - Setter

- (void)setQuality:(CGFloat)quality {
    _quality = quality / (1024 * 1024.0);
}

@end
