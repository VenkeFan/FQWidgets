//
//  WLPostStatusMenu.h
//  welike
//
//  Created by gyb on 2018/11/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WLPostStatusMenu;

@protocol WLPostStatusMenuDelegate <NSObject>

//- (void)interestView:(WLPostStatusMenu *)view didRecviceItems:(NSArray *)items;
- (void)interestView:(WLPostStatusMenu *)view didSetCurrentIndex:(NSInteger)currentIndex preIndex:(NSInteger)preIndex;

//- (void)interestView:(WLPostStatusMenu *)view refreshWhenIntrestErrorReload:(NSArray<WLVerticalItem *> *)items withCurrentIndex:(NSInteger)currentIndex;

@end

@interface WLPostStatusMenu : UIView

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, readonly) NSInteger preIndex;
@property (nonatomic, weak) id<WLPostStatusMenuDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
