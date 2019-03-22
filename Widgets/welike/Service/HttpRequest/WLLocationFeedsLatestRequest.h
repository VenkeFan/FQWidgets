//
//  WLLocationFeedsLatestRequest.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^requestSuccessed)(NSArray *feeds, BOOL last, NSInteger pageNum);

@interface WLLocationFeedsLatestRequest : RDBaseRequest

@property (copy,nonatomic)  NSString *placeId;


- (id)initLocationFeedsLatest:(NSString *)placeId;

- (void)locationOfLatestFeeds:(NSInteger)pageNum successed:(requestSuccessed)successed error:(failedBlock)error;


@end
