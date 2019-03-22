//
//  WLLoginRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "WLAccountManager.h"

typedef void(^loginSuccessed)(WLAccount *account, WLAccountSetting *setting);

@interface WLLoginRequest : RDBaseRequest

- (id)initLoginRequest;
- (void)loginWithMobile:(NSString *)mobile smsCode:(NSString *)smsCode successed:(loginSuccessed)successed error:(failedBlock)error;

@end
