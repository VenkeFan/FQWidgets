//
//  WLUserDetailOperateView.h
//  welike
//
//  Created by fan qi on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUserDetailOperateContentHeight (48)
#define kUserDetailOperateHeight        (kUserDetailOperateContentHeight + kSafeAreaBottomY)

@class WLUser, WLUserDetailOperateView;

@protocol WLUserDetailOperateViewDelegate <NSObject>

- (void)userDetailOperateViewDidClickSendMsg:(WLUserDetailOperateView *)operateView;

@end

@interface WLUserDetailOperateView : UIView

@property (nonatomic, strong) WLUser *user;
@property (nonatomic, weak) id<WLUserDetailOperateViewDelegate> delegate;

@end
