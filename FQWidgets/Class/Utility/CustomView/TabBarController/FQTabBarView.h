//
//  FQTabBarView.h
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQBadgeView.h"

@class FQTabBarView, FQTabBarItem;

typedef NS_ENUM(NSInteger, FQTabBarItemType) {
    FQTabBarItemType_Exclusive,
    FQTabBarItemType_Present
};

@protocol FQTabBarViewDelegate <NSObject>

- (void)tabBarView:(FQTabBarView *)tabBarView didSelectItem:(FQTabBarItem *)item index:(NSUInteger)index;

@end

@interface FQTabBarView : UIView

@property (nonatomic, copy) NSArray<FQTabBarItem *> *items;
@property (nonatomic, weak) id<FQTabBarViewDelegate> delegate;

@end

@interface FQTabBarItem : UIView

@property (nonatomic, assign) FQTabBarItemType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imgName;
@property (nonatomic, copy) NSString *selectedImgName;
@property (nonatomic, assign) NSInteger badgeNum;

@property(nonatomic,getter=isSelected) BOOL selected;

- (instancetype)initWithType:(FQTabBarItemType)type;

@end
