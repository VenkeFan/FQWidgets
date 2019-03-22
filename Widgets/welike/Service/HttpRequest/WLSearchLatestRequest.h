//
//  WLSearchLatestRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^searchLatestSuccessed)(NSArray *posts, NSArray *users, BOOL last, NSInteger pageNum);

@interface WLSearchLatestRequest : RDBaseRequest

- (id)initSearchLatestRequest;
- (void)searchWithKeyword:(NSString *)keyword pageNum:(NSInteger)pageNum successed:(searchLatestSuccessed)successed error:(failedBlock)error;

@end
