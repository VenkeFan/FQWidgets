//
//  WLFeedCell.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYLabel.h"
#import "WLPollView.h"
#import "WLFeedArticleView.h"
#import "WLThumbnailView.h"
#import "WLFeedLayout.h"
#import "WLVideoPost.h"
#import "WLHeadView.h"
#import "WLFollowButton.h"
#import "WLImageButton.h"
#import "WLTrackerPostRead.h"

#define kFeedToolBarFontSize                    10.0
#define kFeedToolBarNormalFontColor             kUIColorFromRGB(0x313131)
#define kFeedToolBarRedFontColor                kUIColorFromRGB(0xFF6A49)

@class WLFeedCell, WLLinkPost;

@interface WLFeedDeletedView : UIView

@property (nonatomic, weak) WLFeedCell *cell;

@end

@interface WLFeedOtherInfoView : UIView

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedLayout *layout;

@end

@interface WLFeedToolBar : UIView

@property (nonatomic, strong) WLImageButton *shareBtn;
@property (nonatomic, strong) WLImageButton *transpondBtn;
@property (nonatomic, strong) WLImageButton *commentBtn;
@property (nonatomic, strong) WLImageButton *likeBtn;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedLayout *layout;

@end

@interface WLFeedCardView : UIView

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) CATextLayer *descLayer;
@property (nonatomic, strong) CALayer *topLine;
@property (nonatomic, strong) CALayer *bottomLine;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLLinkPost *linkModel;

@end

@interface WLFeedProfileView : UIView <WLHeadViewDelegate, WLFollowButtonDelegate>

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) CATextLayer *timeLayer;
@property (nonatomic, strong) UIImageView *honorIcon;
@property (nonatomic, strong) WLFollowButton *followBtn;
@property (nonatomic, strong) UILabel *readCountLab;
@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedLayout *layout;

- (void)setFollowBtnWithLayout:(WLFeedLayout *)layout;

@end

@interface WLFeedVideoView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedLayout *layout;

- (void)playerViewRemoved;

@end

@interface WLFeedContentView : UIView <TYLabelDelegate, WLPollViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) WLFeedProfileView *profileView;
@property (nonatomic, strong) TYLabel *feedLabel;
@property (nonatomic, strong) UIView *retweetedBackgroundView;
@property (nonatomic, strong) TYLabel *retweetedTextLabel;
@property (nonatomic, strong) WLPollView *pollView;
@property (nonatomic, strong) WLFeedArticleView *articleView;
@property (nonatomic, strong) WLThumbnailView *thumbView;
@property (nonatomic, strong) WLFeedVideoView *videoView;
@property (nonatomic, strong) WLFeedCardView *cardView;
@property (nonatomic, strong) WLFeedToolBar *toolBar;
@property (nonatomic, strong) WLFeedDeletedView *deletedView;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) CALayer *topSign;
@property (nonatomic, strong) WLFeedOtherInfoView *otherInfoView;

@property (nonatomic, weak) WLFeedCell *cell;
@property (nonatomic, weak) WLFeedLayout *layout;

@end

@protocol WLFeedCellDelegate <NSObject>

@optional
- (void)feedCell:(WLFeedCell *)cell didClickedFeed:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedTranspond:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedComment:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedLike:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedUser:(NSString *)userID;
- (void)feedCell:(WLFeedCell *)cell didClickedTopic:(NSString *)topicID;
- (void)feedCell:(WLFeedCell *)cell didClickedArtical:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedVideo:(WLVideoPost *)videoModel;
- (void)feedCell:(WLFeedCell *)cell didClickedArrow:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedLocation:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didClickedShare:(WLFeedLayout *)layout;
- (void)feedCell:(WLFeedCell *)cell didPolled:(WLPollPost *)polledModel;
- (void)feedCellDidFollowLoadingChanged:(WLFeedLayout *)layout;
- (void)feedCellDidFollowLoadingFinished:(WLFeedLayout *)layout;

@end

@interface WLFeedCell : UITableViewCell

@property (nonatomic, strong) WLFeedContentView *feedView;
@property (nonatomic, strong) WLFeedLayout *layout;

@property (nonatomic, weak) id<WLFeedCellDelegate> delegate;

@property (nonatomic, assign) BOOL followLoading;

- (void)setTrackerReadClickedArea:(WLTrackerPostClickedArea)clickedArea;

@end
