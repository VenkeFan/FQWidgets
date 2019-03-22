//
//  WLMagicContentView.h
//  welike
//
//  Created by fan qi on 2018/11/26.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLMagicContentView, WLMagicBasicModel;

@protocol WLMagicCameraViewDelegate <NSObject>

- (void)magicContentViewDidSelectedModel:(WLMagicBasicModel *)selectedModel;
- (void)magicContentViewDidSwiped:(UISwipeGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLMagicContentView : UIView

@property (nonatomic, weak) id<WLMagicCameraViewDelegate> delegate;

- (void)fetchFilterArray;
- (void)display;
- (void)displayWithIndex:(NSInteger)index;
- (void)dismiss;

- (WLMagicBasicModel *)previousFilter;
- (WLMagicBasicModel *)nextFilter;

@end

NS_ASSUME_NONNULL_END
