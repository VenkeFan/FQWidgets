//
//  WLUserFollowTabView.h
//  welike
//
//  Created by fan qi on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUserFollowTabViewHeight            56

@class WLUserBase, WLUserFollowTabView;

@protocol WLUserFollowTabViewDelegate <NSObject>

- (void)userFollowTabViewDidSelectedFollowing:(WLUserFollowTabView *)followView;
- (void)userFollowTabViewDidSelectedFollowed:(WLUserFollowTabView *)followView;
- (void)userFollowTabViewDidSelectedPosts:(WLUserFollowTabView *)followView;

@end

@interface WLUserFollowTabView : UIView

@property (nonatomic, strong) WLUserBase *user;
@property (nonatomic, weak) id<WLUserFollowTabViewDelegate> delegate;

@end
