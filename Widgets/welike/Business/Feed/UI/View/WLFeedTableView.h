//
//  WLFeedTableView.h
//  welike
//
//  Created by fan qi on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBasicTableView.h"
#import "WLFeedsProvider.h"
#import "WLFeedsManager.h"
#import "WLMixedPlayerView.h"
#import "WLTrackerFeed.h"
#import "WLFeedCell.h"

@interface WLFeedTableView : WLBasicTableView <WLMixedPlayerViewProtocol, WLFeedCellDelegate>

@property (nonatomic, strong, readonly) WLFeedsManager *feedManager;
- (void)setDataSourceProvider:(id<WLFeedsProvider>)provider uid:(NSString *)uid;

@end

@interface WLFeedTableView (WLTracker)

@property (nonatomic, assign) WLTrackerFeedAction trackerAction;

- (void)appendRefreshTrackerWithFetchCount:(NSUInteger)fetchCount;
- (void)appendMoreTrackerWithFetchCount:(NSUInteger)fetchCount;

@end
