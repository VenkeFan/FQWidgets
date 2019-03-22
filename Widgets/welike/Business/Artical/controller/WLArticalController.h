//
//  WLArticalController.h
//  welike
//
//  Created by gyb on 2019/2/23.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WLFeedLayout;
@class WLPostBase;
@class WLArticalPostModel;
@interface WLArticalController : WLNavBarBaseViewController

@property (strong,nonatomic) WLArticalPostModel *postModel;
@property (nonatomic, assign) BOOL scrollToSegment;

- (instancetype)initWithID:(NSString *)ID;
- (instancetype)initWithOriginalFeedLayout:(WLPostBase *)postBase;


@end

NS_ASSUME_NONNULL_END
