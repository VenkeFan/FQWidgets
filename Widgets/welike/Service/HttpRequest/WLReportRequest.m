//
//  WLReportRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLReportRequest.h"
#import "WLPostBase.h"

@implementation WLReportRequest

- (id)initReportRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"report/report/%@/report", uid] method:AFHttpOperationMethodPOST];
}

- (void)reportWithPost:(WLPostBase *)post reason:(NSString *)reason successed:(reportSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:post.pid forKey:@"reportId"];
    [self.params setObject:post.uid forKey:@"postUserId"];
    if ([reason length] > 0)
    {
        [self.params setObject:reason forKey:@"reason"];
    }
    
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed();
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
