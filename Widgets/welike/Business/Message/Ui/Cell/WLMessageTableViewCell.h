//
//  WLMessageTableViewCell.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIMCommon.h"
#import "WLIMMessage+MessageCell.h"
//#import "WLIMTextMessage+MessageCell.h"
//#import "WLIMPicMessage+MessageCell.h"
//#import "WLIMAudioMessage+MessageCell.h"
//#import "WLIMVideoMessage+MessageCell.h"
//#import "WLIMNoticeMessage+MessageCell.h"
//#import "WLIMEmotionMessage+MessageCell.h"

#import "WLHeadView.h"

#define kMessageCellLeftMargin                  15.f
#define kMessageCellTopMargin                   20.f
#define kMessageCellAvatarSize                  35.f
#define kMessageCellNameLablePading             15.f
#define kMessageCellNameLableHeight             17.f
#define kMessageBubblePading                    15.f
#define kMessageBubbleMaxWidth                  (kScreenWidth>320?218.f:188)
#define kMessageBubbleMinHeight                 42.f
#define kMessageStateButtonSize                 22.f
#define kMessageSectionHeadTimeHeight           17.f

#define kTextMessageCellTextLeftPading          15.f
#define kTextMessageCellTextTopPading           12.f
#define kTextMessageCellTextMinHeight           18.f
#define kTextMessageCellMinHeight (kMessageCellTopMargin+2*kTextMessageCellTextTopPading+kTextMessageCellTextMinHeight)
#define kTextMessageCellTextMaxWidth (kMessageBubbleMaxWidth-2*kTextMessageCellTextLeftPading)

#define kPicMessageCellWidth                    200.f
#define kPicMessageCellHeight                   200.f

#define kMessageSectionHeadTimeFontSize         14.f
#define kNoticeMessageCellFontSize              14.f

#define MessageImageCacheKey                    @"MessageImageCache"

@class WLMessageTableViewCell;

@protocol WLMessageTableViewCellDelegate<NSObject>

@optional

- (void)message:(WLIMMessage *)message avatarViewPressed:(WLHeadView *)avatarView;
- (void)message:(WLIMMessage *)message avatarViewLongPressed:(UILongPressGestureRecognizer *)longPress;
- (void)messageCell:(WLMessageTableViewCell *)cell longPressed:(UILongPressGestureRecognizer *)longPress;
- (void)message:(WLIMMessage *)message didTouchBubbleImageView:(WLMessageTableViewCell *)cell;
- (void)message:(WLIMMessage *)message didTouchStateView:(WLMessageTableViewCell *)cell;
- (void)message:(WLIMMessage *)message didTouchLinkUrl:(NSString *)linkUrl;

@end

@interface WLMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *bubbleImageView; //气泡

@property (nonatomic, assign) BOOL showUserName;
@property (nonatomic, strong) WLIMMessage *message;
@property (nonatomic, weak) id <WLMessageTableViewCellDelegate> delegate;

+ (instancetype)reusableCellOfTableView:(UITableView *)tableView;

- (void)bindMessage:(WLIMMessage *)message;

- (CGSize)bubbleSize;

@end

@interface WLMessageSectionHeaderView : UIView

- (void)setSetionTimeStamp:(NSTimeInterval)timeStamp;

@end
