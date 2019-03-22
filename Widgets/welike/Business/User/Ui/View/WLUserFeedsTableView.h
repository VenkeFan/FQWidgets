//
//  WLUserFeedsTableView.h
//  welike
//
//  Created by fan qi on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLScrollViewCell.h"
#import "WLFeedsProvider.h"
#import "WLFeedTableView.h"
#import "WLFeedLayout.h"

@interface WLUserFeedsTableView : UIView <WLScrollContentViewProtocol>

- (void)setProvider:(id<WLFeedsProvider>)provider userID:(NSString *)userID;
@property (nonatomic, strong, readonly) WLFeedTableView *tableView;

@end
