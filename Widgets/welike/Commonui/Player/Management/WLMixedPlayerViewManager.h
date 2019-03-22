//
//  WLMixedPlayerViewManager.h
//  welike
//
//  Created by fan qi on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLMixedPlayerView;

@interface WLMixedPlayerViewManager : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
+ (instancetype)instance;

- (WLMixedPlayerView *)generateMixedPlayerView;
- (void)destroyMixedPlayerView;

@property (nonatomic, strong, readonly) WLMixedPlayerView *mixedPlayerView;

@end
