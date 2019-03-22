//
//  WLFeedCommentTableView.h
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLScrollViewCell.h"

@class WLFeedCommentTableView, WLCommentLayout, WLFeedCommentCell;

typedef NS_ENUM (NSInteger, WLFeedCommentSortType) {
    WLFeedCommentSortType_Top,
    WLFeedCommentSortType_Latest
};

@protocol WLFeedCommentTableViewDelegate <NSObject>

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedCell:(WLFeedCommentCell *)cell layout:(WLCommentLayout *)layout;
- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedUser:(NSString *)userID;
- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedTopic:(NSString *)topicID;
- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedTranspond:(WLCommentLayout *)layout;
- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedComment:(WLCommentLayout *)layout;
- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedChild:(WLCommentLayout *)layout;

@end

@interface WLFeedCommentTableView : WLScrollContentView

@property (nonatomic, copy) NSString *pid;
@property (nonatomic, assign) WLFeedCommentSortType sortType;
@property (nonatomic, weak) id<WLFeedCommentTableViewDelegate> delegate;

- (void)deleteComment:(WLCommentLayout *)layout cell:(WLFeedCommentCell *)cell;

@end
