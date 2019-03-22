//
//  WLBlockUsersListRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLUser;

typedef void(^blockListSuccessed)(NSArray<WLUser *> *users, NSString *cursor);

@interface WLBlockUsersListRequest : RDBaseRequest

- (id)initBlockUsersListRequestWithUid:(NSString *)uid;
- (void)refreshAndSuccessed:(blockListSuccessed)successed error:(failedBlock)error;
- (void)hisWithCursor:(NSString *)cursor successed:(blockListSuccessed)successed error:(failedBlock)error;

@end
