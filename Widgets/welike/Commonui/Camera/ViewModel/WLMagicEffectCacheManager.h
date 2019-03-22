//
//  WLMagicEffectCacheManager.h
//  welike
//
//  Created by fan qi on 2018/11/30.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLMagicBasicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLMagicEffectCacheManager : NSObject

+ (instancetype)instance;

- (BOOL)isExist:(NSString *)key effectType:(WLMagicBasicModelType)effectType dstPath:(NSString **)dstPath;
- (void)moveFileAtPath:(NSString *)srcPath
       toPathComponent:(NSString *)dstPathComponent
            effectType:(WLMagicBasicModelType)effectType
             completed:(void(^)(NSString *dstPath))completed;

@end

NS_ASSUME_NONNULL_END
