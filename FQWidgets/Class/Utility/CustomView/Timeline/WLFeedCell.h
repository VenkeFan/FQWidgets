//
//  WLFeedCell.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLTimelineViewModel.h"
#import "WLLabel.h"
#import "FQThumbnailView.h"

@class WLFeedCell;

@interface WLFeedToolBar : UIView

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedModel *itemModel;

@end

@interface WLFeedCardView : UIView

@property (nonatomic, strong) CALayer *coverLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CATextLayer *descLayer;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedModel *itemModel;

@end

@interface WLFeedProfileView : UIView

@property (nonatomic, strong) CALayer *avatarLayer;
@property (nonatomic, strong) CATextLayer *nameLayer;
@property (nonatomic, strong) CATextLayer *timeLayer;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedModel *itemModel;

@end

@interface WLFeedContentView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) WLFeedProfileView *profileView;
@property (nonatomic, strong) WLLabel *feedLabel;
@property (nonatomic, strong) UIView *retweetedView;
@property (nonatomic, strong) WLLabel *retweetedLabel;
@property (nonatomic, strong) FQThumbnailView *thumbView;
@property (nonatomic, strong) WLFeedCardView *cardView;
@property (nonatomic, strong) WLFeedToolBar *toolBar;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedModel *itemModel;

@end

@protocol WLFeedCellDelegate <NSObject>

- (void)feedCell:(WLFeedCell *)cell didClickedTranspond:(WLFeedModel *)itemModel;
- (void)feedCell:(WLFeedCell *)cell didClickedComment:(WLFeedModel *)itemModel;
- (void)feedCell:(WLFeedCell *)cell didClickedLike:(WLFeedModel *)itemModel;
- (void)feedCell:(WLFeedCell *)cell didClickedUser:(WLUser *)userModel;

@end

@interface WLFeedCell : UITableViewCell

@property (nonatomic, strong) WLFeedContentView *feedView;
@property (nonatomic, strong) WLFeedModel *itemModel;

@property (nonatomic, weak) id<WLFeedCellDelegate> delegate;

@end
