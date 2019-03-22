//
//  WLBannerManager.m
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBannerManager.h"
#import "WLBannerHomeRequest.h"
#import "WLBannerDiscoveryRequest.h"

@implementation WLBannerManager {
    WLBannerManagerType _type;
}

- (instancetype)initWithType:(WLBannerManagerType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (void)loadBannerWithSucceed:(homeBannerSuccessed)succeed failed:(homeBannerFailed)failed {
    switch (_type) {
        case WLBannerManagerType_Home:
            [self loadHomeBannerWithSucceed:succeed failed:failed];
            break;
        case WLBannerManagerType_Discovery:
            [self loadDiscoveryBannerWithSucceed:succeed failed:failed];
            break;
    }
}

- (void)loadHomeBannerWithSucceed:(homeBannerSuccessed)succeed failed:(homeBannerFailed)failed {
    WLBannerHomeRequest *request = [[WLBannerHomeRequest alloc] init];
    [request fetchHomeBannerWithSucceed:^(NSArray *banners) {
        if (succeed) {
            succeed(banners);
        }
    } failed:^(NSInteger errorCode) {
        if (failed) {
            failed(errorCode);
        }
    }];
}

- (void)loadDiscoveryBannerWithSucceed:(homeBannerSuccessed)succeed failed:(homeBannerFailed)failed {
    WLBannerDiscoveryRequest *request = [[WLBannerDiscoveryRequest alloc] init];
    [request fetchDiscoveryBannerWithSucceed:^(NSArray *banners) {
        if (succeed) {
            succeed(banners);
        }
    } failed:^(NSInteger errorCode) {
        if (failed) {
            failed(errorCode);
        }
    }];
}

@end
