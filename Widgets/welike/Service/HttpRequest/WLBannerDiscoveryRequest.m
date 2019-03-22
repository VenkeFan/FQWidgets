//
//  WLBannerDiscoveryRequest.m
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBannerDiscoveryRequest.h"
#import "WLBannerModel.h"

@implementation WLBannerDiscoveryRequest

- (instancetype)init {
    if ([AppContext getInstance].accountManager.isLogin) {
        return [super initWithType:AFHttpOperationTypeNormal api:@"conplay/active/banner" method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:@"conplay/skip/active/banner" method:AFHttpOperationMethodGET];
    }
}

- (void)fetchDiscoveryBannerWithSucceed:(discoverBannerSuccessed)succeed failed:(failedBlock)failed {
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *banners = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id bannersObj = [resDic objectForKey:@"banners"];
            
            if ([bannersObj isKindOfClass:[NSArray class]]) {
                NSArray *bannersJSON = (NSArray *)bannersObj;
                banners = [NSMutableArray arrayWithCapacity:[bannersJSON count]];
                
                for (NSInteger i = 0; i < [bannersJSON count]; i++)
                {
                    WLBannerModel *bannerModel = [WLBannerModel parseFromNetworkJSON:bannersJSON[i]];
                    [banners addObject:bannerModel];
                }
            }
            
            if (succeed) {
                succeed(banners);
            }
            
        } else {
            if (failed) {
                failed(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}

@end
