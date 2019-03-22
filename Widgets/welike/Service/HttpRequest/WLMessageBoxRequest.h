//
//  WLMessageBoxRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^messageBoxSuccessed)(NSArray *messages, NSString *cursor);

@interface WLMessageBoxRequest : RDBaseRequest

- (id)initMessageBoxRequestWithUid:(NSString *)uid;
- (void)listWithType:(NSString *)messageBoxType cursor:(NSString *)cursor successed:(messageBoxSuccessed)successed error:(failedBlock)error;

@end
