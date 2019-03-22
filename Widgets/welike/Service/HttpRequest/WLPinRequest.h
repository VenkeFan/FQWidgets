//
//  WLPinRequest.h
//  welike
//
//  Created by gyb on 2019/1/16.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PinSuccessed)(BOOL result);


@interface WLPinRequest : RDBaseRequest

-(instancetype)initPin:(NSString *)pid;

-(instancetype)initUnPin:(NSString *)pid;

-(void)pinPost:(NSString *)pid succeed:(PinSuccessed)succeed failed:(failedBlock)failed;

-(void)unPinPost:(NSString *)pid succeed:(PinSuccessed)succeed failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
