//
//  WLVerticalFeedsTypeRequest.h
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//  垂类除了for you之外其他的的类别

#import "RDBaseRequest.h"

typedef void(^VerticalFeedsTypeRequestSuccessed)(NSArray *feeds,NSString *cursor);

@interface WLVerticalFeedsTypeRequest : RDBaseRequest

- (instancetype)init;

- (void)requestVerticalFeedsWithCursor:(NSString *)cursor interestId:(NSString *)interestId successed:(VerticalFeedsTypeRequestSuccessed)successed error:(failedBlock)error;



@end
