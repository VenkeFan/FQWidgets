//
//  WLSMSCodeRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^smsCodeSuccessed)(void);

@interface WLSMSCodeRequest : RDBaseRequest

- (id)initSMSCodeRequest;
- (void)reqSMSCodeWithMobile:(NSString *)mobile nationCode:(NSString *)nationCode successed:(smsCodeSuccessed)successed error:(failedBlock)error;

@end
