//
//  WLLocationDetailRequest.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "WLLocationDetail.h"

typedef void(^locationDetailRequestSuccessed)(WLLocationDetail *locationInfo);

@interface WLLocationDetailRequest : RDBaseRequest

@property (copy,nonatomic)  NSString *placeId;

- (id)initLocationDetial:(NSString *)placeId;

- (void)locationDetial:(locationDetailRequestSuccessed)successed error:(failedBlock)error;

@end
