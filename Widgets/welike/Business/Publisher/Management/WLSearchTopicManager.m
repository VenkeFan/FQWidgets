//
//  WLSearchTopicManager.m
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchTopicManager.h"
#import "WLPublishTopicHotRequest.h"
#import "WLHistoryCache.h"
#import "WLTopicInfoModel.h"
#import "WLSearchTopicRequest.h"


@interface WLSearchTopicManager ()

@property (nonatomic, strong) WLPublishTopicHotRequest *publishTopicHotRequest;
@property (nonatomic, strong) WLSearchTopicRequest *searchTopicRequest;

@end


@implementation WLSearchTopicManager

-(void)listFiveHotTopics:(listHotTopicCompleted)callback
{
    if (self.publishTopicHotRequest != nil)
    {
        [self.publishTopicHotRequest cancel];
        self.publishTopicHotRequest = nil;
    }
    
     __weak typeof(self) weakSelf = self;
    
    self.publishTopicHotRequest = [[WLPublishTopicHotRequest alloc] init];
    
    [self.publishTopicHotRequest tryPublishTopicHot:^(NSArray *topics) {
        weakSelf.publishTopicHotRequest = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(topics, ERROR_SUCCESS);
            }
        });
 
    } error:^(NSInteger errorCode) {
        weakSelf.publishTopicHotRequest = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(nil, errorCode);
            }
        });
    }];
}

-(void)listRecentTopics:(listHotTopicCompleted)callback
{
    [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_TOPIC listRecentResults:^(NSArray *results, BOOL hasMore) {
        NSMutableArray *topics = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (WLSearchHistory *history in results)
        {
            WLTopicInfoModel *topicInfoModel = [[WLTopicInfoModel alloc] init];
            topicInfoModel.topicName = history.keyword;
            
            if (history.keyword.length != 0)
            {
                 [topics addObject:topicInfoModel];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(topics, ERROR_SUCCESS);
            }
        });
    }];
}

-(void)listAllRecommondTopics:(NSString *)key  callback:(listHotTopicCompleted)callback
{
    if (self.searchTopicRequest != nil)
    {
        [self.searchTopicRequest cancel];
        self.searchTopicRequest = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.searchTopicRequest = [[WLSearchTopicRequest alloc] initWithTopicKeyWord:key];
    
    [self.searchTopicRequest searchRecommandTopics:^(NSArray *topics) {
        weakSelf.searchTopicRequest = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(topics, ERROR_SUCCESS);
            }
        });
        
    } error:^(NSInteger errorCode) {
        weakSelf.searchTopicRequest = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(nil, errorCode);
            }
        });
    }];
}


@end
