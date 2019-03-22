//
//  WLHotFeedsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^hotFeedsSuccessed)(NSArray *feeds, NSString *cursor);

@interface WLHotFeedsRequest : RDBaseRequest

- (id)initHotFeedsRequest;
- (void)tryHotFeedsWithCursor:(NSString *)cursor successed:(hotFeedsSuccessed)successed error:(failedBlock)error;

@end
