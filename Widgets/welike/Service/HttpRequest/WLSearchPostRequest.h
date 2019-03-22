//
//  WLSearchPostRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^searchPostsSuccessed)(NSArray *posts, BOOL last, NSInteger pageNum);

@interface WLSearchPostRequest : RDBaseRequest

- (id)initSearchPostRequest;
- (void)searchWithKeyword:(NSString *)keyword pageNum:(NSInteger)pageNum successed:(searchPostsSuccessed)successed error:(failedBlock)error;

@end
