//
//  WLPlayerCollectionView.h
//  welike
//
//  Created by fan qi on 2018/8/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRotatableView.h"
#import "WLMixedPlayerView.h"

@class WLVideoPost;

@interface WLPlayerCollectionView : WLRotatableView <WLMixedPlayerViewProtocol>

- (instancetype)init __attribute__((unavailable("Use -initWithPostID:instead")));
+ (instancetype)new __attribute__((unavailable("Use -initWithPostID:instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithPostID:instead")));

- (instancetype)initWithPostID:(NSString *)postID;

- (void)displayWithSubView:(UIView *)subView;
- (void)displayWithSubView:(UIView *)subView videoModel:(WLVideoPost *)videoModel;

@end
