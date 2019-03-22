//
//  WLVerticalVideoRequest.h
//  welike
//
//  Created by gyb on 2018/8/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^VerticalVideoFeedsRequestSuccessed)(NSArray *feeds,NSString *cursor);

@interface WLVerticalVideoRequest : RDBaseRequest

- (instancetype)init;

- (void)requestVerticalVideoFeedsWithCursor:(NSString *)cursor  interests:(NSArray *)interests successed:(VerticalVideoFeedsRequestSuccessed)successed error:(failedBlock)error;


@end
