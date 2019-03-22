//
//  WLTopicInfoRequest.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLTopicInfoModel, WLPostBase;

typedef void(^requsetSuccessed)(WLTopicInfoModel *topic, WLPostBase *topPost);

@interface WLTopicInfoRequest : RDBaseRequest

- (instancetype)initWithTopicID:(NSString *)topicID;
- (void)fetchTopicInfoWithSucceed:(requsetSuccessed)succeed failed:(failedBlock)failed;

@end
