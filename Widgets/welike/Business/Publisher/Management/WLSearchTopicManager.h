//
//  WLSearchTopicManager.h
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"


typedef void(^listHotTopicCompleted) (NSArray *topics, NSInteger errCode);


@interface WLSearchTopicManager : NSObject


-(void)listFiveHotTopics:(listHotTopicCompleted)callback;
-(void)listRecentTopics:(listHotTopicCompleted)callback;

-(void)listAllRecommondTopics:(NSString *)key  callback:(listHotTopicCompleted)callback;


@end
