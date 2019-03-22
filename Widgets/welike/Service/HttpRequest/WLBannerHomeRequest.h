//
//  WLBannerHomeRequest.h
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^homeBannerSuccessed)(NSArray *banners);

@interface WLBannerHomeRequest : RDBaseRequest

- (void)fetchHomeBannerWithSucceed:(homeBannerSuccessed)succeed failed:(failedBlock)failed;

@end
