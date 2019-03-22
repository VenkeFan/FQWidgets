//
//  WLHomeFeedsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^homeFeedsSuccessed)(NSArray *feeds, NSString *cursor);

@interface WLHomeFeedsRequest : RDBaseRequest

- (id)initHomeFeedsRequestWithUid:(NSString *)uid;
- (void)tryHomeFeedsWithCursor:(NSString *)cursor successed:(homeFeedsSuccessed)successed error:(failedBlock)error;

@end
