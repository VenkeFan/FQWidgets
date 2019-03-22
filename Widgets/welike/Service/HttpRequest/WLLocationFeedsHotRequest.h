//
//  WLLocationFeedsHotRequest.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^locationHotFeedsRequestSuccessed)(NSArray *feeds,NSString *cursor);

@interface WLLocationFeedsHotRequest : RDBaseRequest

@property (copy,nonatomic)  NSString *placeId;

- (id)initLocationHotFeeds:(NSString *)placeId;

- (void)locationOfHotFeeds:(NSString *)cursor successed:(locationHotFeedsRequestSuccessed)successed error:(failedBlock)error;

@end
