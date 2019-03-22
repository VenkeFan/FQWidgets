//
//  WLFeedCommentCell.h
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLCommentLayout.h"

@class WLFeedCommentCell;

@protocol WLFeedCommentCellDelegate <NSObject>

@optional
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedSelf:(WLCommentLayout *)layout;
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedUser:(NSString *)userID;
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedTopic:(NSString *)topicID;
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedTranspond:(WLCommentLayout *)layout;
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedComment:(WLCommentLayout *)layout;
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedLike:(WLCommentLayout *)layout;
- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedChild:(WLCommentLayout *)layout;

@end

@interface WLFeedCommentCell : UITableViewCell

@property (nonatomic, strong) WLCommentLayout *layout;

@property (nonatomic, weak) id<WLFeedCommentCellDelegate> delegate;

@end
