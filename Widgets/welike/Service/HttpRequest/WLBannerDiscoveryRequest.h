//
//  WLBannerDiscoveryRequest.h
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^discoverBannerSuccessed)(NSArray *banners);

@interface WLBannerDiscoveryRequest : RDBaseRequest

- (void)fetchDiscoveryBannerWithSucceed:(discoverBannerSuccessed)succeed failed:(failedBlock)failed;

@end
