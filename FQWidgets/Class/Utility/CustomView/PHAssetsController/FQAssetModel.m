//
//  FQAssetModel.m
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetModel.h"

@implementation FQAssetModel

#pragma mark - LifeCycle

- (instancetype)initWithType:(FQAssetModelType)type asset:(PHAsset *)asset {
    if (self = [super init]) {
        _type = type;
        _asset = asset;
        _checked = NO;
        _checkedIndex = -1;
        _quality = 0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
    
    //    FQAssetModel *copyModel = [[[self class] allocWithZone:zone] initWithType:_type asset:_asset];
    //    copyModel.checked = _checked;
    //    copyModel.checkedIndex = _checkedIndex;
    //    return copyModel;
}

#pragma mark - Setter

- (void)setQuality:(CGFloat)quality {
    _quality = quality / (1024 * 1024.0);
}

@end
