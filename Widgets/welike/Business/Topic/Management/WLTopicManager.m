//
//  WLTopicManager.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicManager.h"
#import "WLTopicInfoRequest.h"
#import "WLTopicResidentRequest.h"
#import "WLTopicInfoModel.h"
#import "WLFeedLayout.h"

@implementation WLTopicManager

- (void)loadTopicInfo:(NSString *)topicID succeed:(topicInfoSuccessed)succeed failed:(topicInfoFailed)failed {
    WLTopicInfoRequest *request = [[WLTopicInfoRequest alloc] initWithTopicID:topicID];
    [request fetchTopicInfoWithSucceed:^(WLTopicInfoModel *topic, WLPostBase *topPost) {
        if (succeed) {
            WLFeedLayout *layout = [WLFeedLayout layoutWithFeedModel:topPost layoutType:WLFeedLayoutType_TopicTop];
            succeed(topic, layout);
        }
    } failed:^(NSInteger errorCode) {
        if (failed) {
            failed(topicID, errorCode);
        }
    }];
}

- (void)loadResidentTopicWithSucceed:(topicResidentSuccessed)succeed failed:(topicInfoFailed)failed {
    WLTopicResidentRequest *request = [[WLTopicResidentRequest alloc] init];
    [request fetchResidentTopicWithSucceed:^(NSArray *dataArray) {
        if (succeed) {
            succeed(dataArray);
        }
    } failed:^(NSInteger errorCode) {
        if (failed) {
            failed(nil, errorCode);
        }
    }];
}

@end
