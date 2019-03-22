//
//  WLPublishTopicHotRequest.h
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLPublishTopicHotRequest : RDBaseRequest

- (instancetype)init;
- (void)tryPublishTopicHot:(void (^)(NSArray * topics))successed error:(failedBlock)error;

@end
