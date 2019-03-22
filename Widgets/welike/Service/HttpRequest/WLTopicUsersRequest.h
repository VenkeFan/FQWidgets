//
//  WLTopicUsersRequest.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^topicUsersSuccessed)(NSArray *users, NSString *cursor);

@interface WLTopicUsersRequest : RDBaseRequest

- (instancetype)initWithTopicID:(NSString *)topicID;
- (void)listWithCursor:(NSString *)cursor index:(NSNumber *)index successed:(topicUsersSuccessed)successed error:(failedBlock)error;

@end
