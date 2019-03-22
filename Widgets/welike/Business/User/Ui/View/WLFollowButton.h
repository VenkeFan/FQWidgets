//
//  WLFollowButton.h
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFollowDefaultFrame     CGRectMake(0, 0, 64, 24)

@class WLUser, WLPostBase, WLFollowButton;

typedef NS_ENUM(NSInteger, WLFollowButtonType) {
    WLFollowButtonType_None,
    WLFollowButtonType_Friends,
    WLFollowButtonType_Following,
    WLFollowButtonType_Followed
};

@protocol WLFollowButtonDelegate <NSObject>

@optional
- (void)followButtonFinished:(WLFollowButton *)followBtn;
- (void)followButtonLoadingChanged:(WLFollowButton *)followBtn;

@end

@interface WLFollowButton : UIButton

@property (nonatomic, strong) WLUser *user;
@property (nonatomic, strong) WLPostBase *feedModel;

@property (nonatomic, assign) WLFollowButtonType type;

@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (nonatomic, weak) id<WLFollowButtonDelegate> delegate;

@end
