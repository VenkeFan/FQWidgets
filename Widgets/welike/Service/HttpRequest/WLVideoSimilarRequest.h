//
//  WLVideoSimilarRequest.h
//  welike
//
//  Created by fan qi on 2018/8/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^videoSimilarSuccessed)(NSArray *videos, NSString *cursor);

@interface WLVideoSimilarRequest : RDBaseRequest

- (instancetype)initWithPostID:(NSString *)postID;
- (void)tryVideoSimilarWithCursor:(NSString *)cursor
                        successed:(videoSimilarSuccessed)successed
                            error:(failedBlock)error;

@end
