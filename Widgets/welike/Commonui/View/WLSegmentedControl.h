//
//  WLSegmentedControl.h
//  welike
//
//  Created by fan qi on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSegmentHeight               40

@class WLSegmentedControl;

@protocol WLSegmentedControlDelegate <NSObject>

@optional
- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index;
- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index preIndex:(NSInteger)preIndex;

@end

@interface WLSegmentedControl : UIControl

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, strong) UIColor *markLineColor;
@property (nonatomic, strong) UIColor *hSeparateLineColor;
@property (nonatomic, strong) UIFont *tintFont;
@property (nonatomic, strong) UIFont *onTintFont;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL hasSeparateLine;
@property (nonatomic, weak) id<WLSegmentedControlDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger preIndex;
@property (nonatomic, assign, readonly, getter=isShowShadow) BOOL showShadow;

- (void)setLineOffsetX:(CGFloat)x;
- (void)hideTitleTipWithIndex:(NSInteger)index;

- (void)addShadow;
- (void)clearShadow;

@end
