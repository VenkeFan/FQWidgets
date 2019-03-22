//
//  WLReportRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^reportSuccessed)(void);

@class WLPostBase;

@interface WLReportRequest : RDBaseRequest

- (id)initReportRequestWithUid:(NSString *)uid;
- (void)reportWithPost:(WLPostBase *)post reason:(NSString *)reason successed:(reportSuccessed)successed error:(failedBlock)error;

@end
