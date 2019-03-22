//
//  WLSearchTopicRequest.h
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLSearchTopicRequest : RDBaseRequest


- (instancetype)initWithTopicKeyWord:(NSString *)keyword;


- (void)searchRecommandTopics:(void (^)(NSArray * topics))successed error:(failedBlock)error;

@end
