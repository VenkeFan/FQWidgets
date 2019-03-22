//
//  WLCommentDetailViewController.h
//  welike
//
//  Created by fan qi on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTableViewController.h"

@class WLFeedLayout, WLCommentLayout;
@class WLPostBase, WLComment;

@interface WLCommentDetailViewController : WLTableViewController

- (instancetype)initWithFeedLayout:(WLFeedLayout *)feedLayout commentLayout:(WLCommentLayout *)commentLayout;
- (instancetype)initWithFeedModel:(WLPostBase *)feedModel commentModel:(WLComment *)commentModel;

@end
