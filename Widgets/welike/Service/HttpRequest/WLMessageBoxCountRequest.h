//
//  WLMessageBoxCountRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^messageBoxCountSuccessed)(NSInteger mention, NSInteger comment, NSInteger like);

@interface WLMessageBoxCountRequest : RDBaseRequest

- (id)initMessageBoxCountRequestWithUid:(NSString *)uid;
- (void)countWithSuccessed:(messageBoxCountSuccessed)successed error:(failedBlock)error;

@end
