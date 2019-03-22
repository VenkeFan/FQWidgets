//
//  WLUserDetailRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLUser;

typedef void(^userDetailSuccessed)(WLUser *user);

@interface WLUserDetailRequest : RDBaseRequest

- (id)initUserDetailRequestWithUid:(NSString *)uid;
- (void)detailSuccessed:(userDetailSuccessed)successed error:(failedBlock)error;

@end
