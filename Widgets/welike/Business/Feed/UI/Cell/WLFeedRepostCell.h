//
//  WLFeedRepostCell.h
//  welike
//
//  Created by fan qi on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLFeedRepostLayout.h"

@class WLFeedRepostCell;

@protocol WLFeedRepostCellDelegate <NSObject>

- (void)feedRepostCell:(WLFeedRepostCell *)cell didClickedFeed:(WLFeedRepostLayout *)layout;
- (void)feedRepostCell:(WLFeedRepostCell *)cell didClickedUser:(NSString *)userID;
- (void)feedRepostCell:(WLFeedRepostCell *)cell didClickedTopic:(NSString *)topicID;

@end

@interface WLFeedRepostCell : UITableViewCell

@property (nonatomic, strong) WLFeedRepostLayout *layout;
@property (nonatomic, weak) id<WLFeedRepostCellDelegate> delegate;

@end
