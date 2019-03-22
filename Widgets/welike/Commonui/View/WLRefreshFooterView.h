//
//  WLRefreshFooterView.h
//  welike
//
//  Created by fan qi on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WLRefreshFooterStatus) {
    WLRefreshFooterStatus_Idle,
    WLRefreshFooterStatus_Pulling,
    WLRefreshFooterStatus_Refreshing
};

typedef NS_ENUM(NSInteger, WLRefreshFooterResult) {
    WLRefreshFooterResult_None,
    WLRefreshFooterResult_NoMore,
    WLRefreshFooterResult_HasMore,
    WLRefreshFooterResult_Error
};

@interface WLRefreshFooterView : UIView

- (void)addTarget:(id)target refreshAction:(SEL)refreshAction;

@property (nonatomic, assign) WLRefreshFooterStatus status;
@property (nonatomic, assign) WLRefreshFooterResult result;

@end
