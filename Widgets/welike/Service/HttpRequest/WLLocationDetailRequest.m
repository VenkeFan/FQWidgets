//
//  WLLocationDetailRequest.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationDetailRequest.h"
#import "WLLocationDetail.h"

@implementation WLLocationDetailRequest

- (id)initLocationDetial:(NSString *)placeId
{
    _placeId = placeId;
    return [super initWithType:AFHttpOperationTypeNormal api:@"lbs/nearest" method:AFHttpOperationMethodGET];
}

- (void)locationDetial:(locationDetailRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:_placeId forKey:@"placeId"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            WLLocationDetail *info = [WLLocationDetail parseFromNetworkJSON:result];
            if (info) {
                if (successed) {
                    successed(info);
                }
            } else {
                if (error) {
                    error(ERROR_NETWORK_RESP_INVALID);
                }
            }
            
        } else {
            if (error) {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}


@end
