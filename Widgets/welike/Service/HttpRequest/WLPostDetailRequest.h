//
//  WLPostDetailRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "WLPostBase.h"

typedef void(^detailPostSuccessed)(WLPostBase *post);

@interface WLPostDetailRequest : RDBaseRequest

- (id)initPostDetailRequestWithPid:(NSString *)pid;
- (void)detailForSuccessed:(detailPostSuccessed)successed error:(failedBlock)error;

@end
