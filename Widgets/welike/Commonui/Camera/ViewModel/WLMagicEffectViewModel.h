//
//  WLMagicEffectViewModel.h
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLMagicFilterModel, WLMagicPasterModel, WLMagicBasicModel;

@interface WLMagicEffectViewModel : NSObject

- (void)fetchEffectFilterArray:(void(^)(NSArray<WLMagicFilterModel *> *list, NSError *error))completed;
- (void)fetchEffectPasterArray:(void(^)(NSArray<WLMagicPasterModel *> *list, NSError *error))completed;

@end
