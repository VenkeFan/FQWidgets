//
//  WLAuthRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "WLAccountManager.h"

typedef void(^authSuccessed)(WLAccount *account);

@interface WLAuthRequest : RDBaseRequest

- (id)initAuthRequest;
- (void)authWithRefreshToken:(NSString *)refreshToken successed:(authSuccessed)successed error:(failedBlock)error;

@end
