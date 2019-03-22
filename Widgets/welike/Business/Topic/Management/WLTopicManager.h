//
//  WLTopicManager.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLTopicInfoModel, WLFeedLayout;

typedef void(^topicInfoSuccessed)(WLTopicInfoModel *topic, WLFeedLayout *topFeedLayout);
typedef void(^topicInfoFailed)(NSString *topicID, NSInteger errorCode);

typedef void(^topicResidentSuccessed)(NSArray *dataArray);

@interface WLTopicManager : NSObject

- (void)loadTopicInfo:(NSString *)topicID succeed:(topicInfoSuccessed)succeed failed:(topicInfoFailed)failed;
- (void)loadResidentTopicWithSucceed:(topicResidentSuccessed)succeed failed:(topicInfoFailed)failed;

@end
