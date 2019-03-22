//
//  WLInfulencerRequest.m
//  welike
//
//  Created by gyb on 2019/3/8.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLInfulencerRequest.h"

@implementation WLInfulencerRequest

- (instancetype)init
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"certify/config/fe/" method:AFHttpOperationMethodGET];
}

-(void)getInfluencer:(InfulencerRequestSuccessed)succeed failed:(failedBlock)failed
{
    self.onSuccessed = ^(id result) {
        
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            NSString *urlStr = resDic[@"userGrade"];
            
            if (succeed)
            {
                succeed(urlStr);
            }
        }
        else
        {
            if (succeed)
            {
                succeed(@"");
            }
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}




@end
