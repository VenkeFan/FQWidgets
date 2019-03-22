//
//  WLCommentOperateView.h
//  welike
//
//  Created by fan qi on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCommentOperateContentHeight             (49)
#define kCommentOperateHeight                    (kCommentOperateContentHeight + kSafeAreaBottomY)

@class WLCommentOperateView;

@protocol WLCommentOperateViewDelegate <NSObject>

@optional
- (void)commentOperateViewDidClickedTranspond:(WLCommentOperateView *)operateView;
- (void)commentOperateViewDidClickedComment:(WLCommentOperateView *)operateView;
- (void)commentOperateViewDidClickedLike:(WLCommentOperateView *)operateView;
- (void)commentOperateViewDidClickedShare:(WLCommentOperateView *)operateView;

@end

@interface WLCommentOperateView : UIView

@property (nonatomic, weak) id<WLCommentOperateViewDelegate> delegate;
@property (nonatomic, assign, getter=isLiked) BOOL liked;

@end

@interface WLCommentDetailOperateView : WLCommentOperateView

@property (nonatomic, strong) UIButton *praiseButton;

@end
