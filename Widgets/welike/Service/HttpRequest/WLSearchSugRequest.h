//
//  WLSearchSugRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^searchSugSuccessed)(NSArray *sugs);

@interface WLSearchSugRequest : RDBaseRequest

- (id)initSearchSugRequest;
- (void)sugKeyword:(NSString *)keyword successed:(searchSugSuccessed)successed error:(failedBlock)error;

@end
