//
//  WLUnloginIntrestView.h
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLUnloginIntrestView, WLVerticalItem;

@protocol WLUnloginIntrestViewDelegate <NSObject>

- (void)interestView:(WLUnloginIntrestView *)view didRecviceItems:(NSArray<WLVerticalItem *> *)items;
- (void)interestView:(WLUnloginIntrestView *)view didSetCurrentIndex:(NSInteger)currentIndex preIndex:(NSInteger)preIndex;

- (void)interestView:(WLUnloginIntrestView *)view refreshWhenIntrestErrorReload:(NSArray<WLVerticalItem *> *)items withCurrentIndex:(NSInteger)currentIndex;

@end


@interface WLUnloginIntrestView : UIView

@property (nonatomic, strong, readonly) NSMutableArray<WLVerticalItem *> *dataArray;
@property (nonatomic, weak) id<WLUnloginIntrestViewDelegate> delegate;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, readonly) NSInteger preIndex;

-(void)refreshWhenError;

@end
