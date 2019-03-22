//
//  WLNickNameCheckRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^nickNameSuccessed)(void);

@interface WLNickNameCheckRequest : RDBaseRequest

@property (nonatomic, readonly) NSString *nickName;

- (id)initNickNameCheckRequest;
- (void)checkForNickName:(NSString *)nickName successed:(nickNameSuccessed)successed error:(failedBlock)error;

@end
