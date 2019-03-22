//
//  WLHomeFollowingFeedsView.h
//  welike
//
//  Created by fan qi on 2018/12/19.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLHomeFollowingFeedsView;

@protocol WLHomeFollowingFeedsViewDelegate <NSObject>

- (void)homeFollowingFeedsViewDidEmptyClicked:(WLHomeFollowingFeedsView *)followingView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLHomeFollowingFeedsView : UIView

- (void)foreceRefresh;
- (void)destroyPlayerView;

@property (nonatomic, weak) id<WLHomeFollowingFeedsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
