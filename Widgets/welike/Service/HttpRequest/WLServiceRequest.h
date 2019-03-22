//
//  WLServiceRequest.h
//  welike
//
//  Created by gyb on 2019/3/9.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class WLUser;

typedef void(^ServiceUserRequestSuccessed)(WLUser *user);

//typedef void(^failedBlock) (NSInteger errorCode);

@interface WLServiceRequest : RDBaseRequest

-(void)getServiceUser:(ServiceUserRequestSuccessed)succeed failed:(failedBlock)failed;



@end

NS_ASSUME_NONNULL_END
