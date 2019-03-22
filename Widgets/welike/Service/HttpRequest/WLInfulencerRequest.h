//
//  WLInfulencerRequest.h
//  welike
//
//  Created by gyb on 2019/3/8.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^InfulencerRequestSuccessed)(NSString *str);

@interface WLInfulencerRequest : RDBaseRequest

-(void)getInfluencer:(InfulencerRequestSuccessed)succeed failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
