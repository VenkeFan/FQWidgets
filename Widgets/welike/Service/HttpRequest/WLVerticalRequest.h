//
//  WLVerticalRequest.h
//  welike
//
//  Created by gyb on 2018/7/23.
//  Copyright © 2018年 redefine. All rights reserved.
//  未登录时,首页分类的接口

#import "RDBaseRequest.h"

typedef void(^VerticalRequestSuccessed)(NSArray *feeds);


@interface WLVerticalRequest : RDBaseRequest

- (instancetype)init;

- (void)requestVerticalFeedsWithPageNum:(NSInteger)pageNum successed:(VerticalRequestSuccessed)successed error:(failedBlock)error;

@end
