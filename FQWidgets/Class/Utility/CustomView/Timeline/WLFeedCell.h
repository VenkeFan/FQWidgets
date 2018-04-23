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

@interface WLFeedToolBar : UIView

@end

@interface WLFeedCardView : UIView

@property (nonatomic, strong) CALayer *coverLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CATextLayer *descLayer;

- (void)setItemModel:(WLFeedModel *)itemModel;

@end

@interface WLFeedProfileView : UIView

@property (nonatomic, strong) CALayer *avatarLayer;
@property (nonatomic, strong) CATextLayer *nameLayer;
@property (nonatomic, strong) CATextLayer *timeLayer;

- (void)setItemModel:(WLFeedModel *)itemModel;

@end

@interface WLFeedContentView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) WLFeedProfileView *profileView;
@property (nonatomic, strong) WLLabel *feedLabel;
@property (nonatomic, strong) FQThumbnailView *thumbView;

@property (nonatomic, strong) WLFeedCardView *cardView;
@property (nonatomic, strong) WLFeedToolBar *toolBar;

- (void)setItemModel:(WLFeedModel *)itemModel;

@end

@interface WLFeedCell : UITableViewCell

@property (nonatomic, strong) WLFeedContentView *feedView;
@property (nonatomic, strong) WLFeedModel *itemModel;

@end
