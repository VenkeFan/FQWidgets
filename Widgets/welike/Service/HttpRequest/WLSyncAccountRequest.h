//
//  WLSyncAccountRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLAccount;
@class WLAccountSetting;

typedef void(^syncAccountSuccessed)(WLAccount *account);
typedef void(^syncAccountSettingSuccessed)(WLAccountSetting *setting);

@interface WLSyncAccountRequest : RDBaseRequest

- (id)initSyncAccountRequest;
- (void)syncAccount:(NSString *)uid info:(NSDictionary *)userInfo successed:(syncAccountSuccessed)successed error:(failedBlock)error;
- (void)syncAccount:(NSString *)uid interests:(NSArray *)interests successed:(syncAccountSuccessed)successed error:(failedBlock)error;
- (void)syncAccount:(NSString *)uid setting:(WLAccountSetting *)account successed:(syncAccountSettingSuccessed)successed error:(failedBlock)error;

@end
