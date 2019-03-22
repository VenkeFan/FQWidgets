//
//  WLFeedDetailViewController.h
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLFeedLayout, WLFeedDetailViewController;
@class WLPollPost, WLPostBase;

@protocol WLFeedDetailViewControllerDelegate <NSObject>

@optional
- (void)feedDetailViewController:(WLFeedDetailViewController *)ctr didDeleted:(WLFeedLayout *)layout;
- (void)feedDetailViewController:(WLFeedDetailViewController *)ctr didPolled:(WLPollPost *)polledModel;

@end

@interface WLFeedDetailViewController : WLNavBarBaseViewController

- (instancetype)initWithID:(NSString *)ID;
- (instancetype)initWithOriginalFeedLayout:(WLFeedLayout *)originalFeedLayout;

@property (nonatomic, strong, readonly) WLPostBase *postModel;
@property (nonatomic, assign) BOOL scrollToSegment;
@property (nonatomic, weak) id<WLFeedDetailViewControllerDelegate> delegate;

@end
