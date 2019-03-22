//
//  WLSearchUserRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^searchUsersSuccessed)(NSArray *users, BOOL last, NSInteger pageNum);

@interface WLSearchUserRequest : RDBaseRequest

- (id)initSearchUserRequest;
- (void)searchWithKeyword:(NSString *)keyword pageNum:(NSInteger)pageNum successed:(searchUsersSuccessed)successed error:(failedBlock)error;

@end
