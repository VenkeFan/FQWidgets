//
//  WLPinRequest.m
//  welike
//
//  Created by gyb on 2019/1/16.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLPinRequest.h"

@implementation WLPinRequest

- (instancetype)initPin:(NSString *)pid
{
      return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/top-post/%@", pid] method:AFHttpOperationMethodPUT];
}

- (instancetype)initUnPin:(NSString *)pid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/top-post/%@", pid] method:AFHttpOperationMethodDELETE];
}

-(void)pinPost:(NSString *)pid succeed:(PinSuccessed)succeed failed:(failedBlock)failed
{
    self.onSuccessed = ^(id result) {
        
        if (succeed)
        {
            succeed(YES);
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}

-(void)unPinPost:(NSString *)pid succeed:(PinSuccessed)succeed failed:(failedBlock)failed
{
    [self.params removeAllObjects];
    
    [self.params setObject:pid forKey:@"pid"];
    
    self.onSuccessed = ^(id result) {
        
        NSLog(@"%@",result);
        
        succeed(result);
        
    };
    self.onFailed = failed;
    [self sendQuery];
}

@end
