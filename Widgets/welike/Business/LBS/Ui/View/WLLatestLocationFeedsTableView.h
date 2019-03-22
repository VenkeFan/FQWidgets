//
//  WLLatestLocationFeedsTableView.h
//  welike
//
//  Created by gyb on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLFeedsProvider.h"
#import "WLFeedTableView.h"
#import "WLFeedLayout.h"
#import "WLScrollViewCell.h"

@interface WLLatestLocationFeedsTableView : UIView<WLScrollContentViewProtocol>

- (void)setProvider:(id<WLFeedsProvider>)provider userID:(NSString *)userID;
@property (nonatomic, strong, readonly) WLFeedTableView *tableView;



@end
