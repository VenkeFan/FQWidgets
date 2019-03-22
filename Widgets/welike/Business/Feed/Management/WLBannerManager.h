//
//  WLBannerManager.h
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLBannerManagerType) {
    WLBannerManagerType_Home,
    WLBannerManagerType_Discovery
};

typedef void(^homeBannerSuccessed)(NSArray *banners);
typedef void(^homeBannerFailed)(NSInteger errorCode);

@interface WLBannerManager : NSObject

- (instancetype)initWithType:(WLBannerManagerType)type;
- (void)loadBannerWithSucceed:(homeBannerSuccessed)succeed failed:(homeBannerFailed)failed;

@end
