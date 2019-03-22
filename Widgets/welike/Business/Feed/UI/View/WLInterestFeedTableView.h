//
//  WLInterestFeedTableView.h
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedTableView.h"

@interface WLInterestFeedTableView : WLFeedTableView

@property (nonatomic, copy) NSString *interestId;
@property (nonatomic, copy) void(^refreshFromTop)(void);

- (void)display;
- (void)refreshFeed;

@end
