//
//  WLBannerHomeRequest.m
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBannerHomeRequest.h"
#import "WLBannerModel.h"

@implementation WLBannerHomeRequest

- (instancetype)init {
    return [super initWithType:AFHttpOperationTypeNormal api:@"conplay/home/banner" method:AFHttpOperationMethodGET];
}

- (void)fetchHomeBannerWithSucceed:(homeBannerSuccessed)succeed failed:(failedBlock)failed {
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
