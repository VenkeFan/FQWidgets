//
//  WLVerticalFeedsRequest.h
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//  未登录时,for you 按钮点击

#import "RDBaseRequest.h"

typedef void(^VerticalFeedsRequestSuccessed)(NSArray *feeds,NSString *cursor);

@interface WLVerticalFeedsRequest : RDBaseRequest

- (instancetype)init;

- (void)requestVerticalFeedsWithCursor:(NSString *)cursor  interests:(NSArray *)interests successed:(VerticalFeedsRequestSuccessed)successed error:(failedBlock)error;



@end
