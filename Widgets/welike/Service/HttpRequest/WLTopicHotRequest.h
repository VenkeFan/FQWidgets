//
//  WLTopicHotRequest.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^topicHotSuccessed)(NSArray *feeds, NSString *cursor);

@interface WLTopicHotRequest : RDBaseRequest

- (instancetype)initWithTopicID:(NSString *)topicID;
- (void)tryTopicHotWithCursor:(NSString *)cursor successed:(topicHotSuccessed)successed error:(failedBlock)error;

@end
