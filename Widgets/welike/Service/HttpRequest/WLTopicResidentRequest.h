//
//  WLTopicResidentRequest.h
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLTopicInfoModel;

typedef void(^topicResidentSuccessed)(NSArray *dataArray);

@interface WLTopicResidentRequest : RDBaseRequest

- (void)fetchResidentTopicWithSucceed:(topicResidentSuccessed)succeed failed:(failedBlock)failed;

@end
