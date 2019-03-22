//
//  WLLatestFeedsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^latestFeedsSuccessed)(NSArray *feeds, NSString *cursor);

@interface WLLatestFeedsRequest : RDBaseRequest

- (id)initLatestFeedsRequest;
- (void)tryLatestFeedsWithCursor:(NSString *)cursor successed:(latestFeedsSuccessed)successed error:(failedBlock)error;

@end
