//
//  WLDeletePostRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^deletePostSuccessed)(NSString *pid);

@interface WLDeletePostRequest : RDBaseRequest

- (id)initDeletePostRequestWithUid:(NSString *)uid pid:(NSString *)pid;
- (void)deletePostForSuccessed:(deletePostSuccessed)successed error:(failedBlock)error;

@end
