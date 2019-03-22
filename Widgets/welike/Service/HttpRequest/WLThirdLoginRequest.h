//
//  WLThirdLoginRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "WLAccountManager.h"

typedef NS_ENUM(NSInteger, WLThirdLoginType) {
    WLThirdLoginType_FaceBook = 1,
    WLThirdLoginType_Google
};

typedef void(^loginSuccessed)(WLAccount *account, WLAccountSetting *setting);

@interface WLThirdLoginRequest : RDBaseRequest

- (id)initThirdLoginRequest;
- (void)loginWithType:(NSInteger)type token:(NSString *)token successed:(loginSuccessed)successed error:(failedBlock)error;

@end
