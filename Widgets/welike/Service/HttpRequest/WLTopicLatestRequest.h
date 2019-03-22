//
//  WLTopicLatestRequest.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^topicLatestSuccessed)(NSArray *feeds, NSString *cursor);

@interface WLTopicLatestRequest : RDBaseRequest

- (instancetype)initWithTopicID:(NSString *)topicID;
- (void)tryTopicLatestWithCursor:(NSString *)cursor successed:(topicLatestSuccessed)successed error:(failedBlock)error;

@end
