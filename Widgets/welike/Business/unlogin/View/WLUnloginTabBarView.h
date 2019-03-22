//
//  WLUnloginTabBarView.h
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOTAnimationView.h"

@class FQTabBarItem;
@class WLUnloginTabBarView;
@protocol WLUnloginTabBarViewDelegate <NSObject>

- (void)tabBarView:(WLUnloginTabBarView *)tabBarView didSelectItem:(FQTabBarItem *)item index:(NSUInteger)index;

@end


@interface WLUnloginTabBarView : UIView
{
    LOTAnimationView *animationView;
}

@property (nonatomic, weak) UIView *publishView;
@property (nonatomic, copy) NSArray<FQTabBarItem *> *items;
@property (nonatomic, weak) id<WLUnloginTabBarViewDelegate> delegate;

-(void)resumeAnimationPlay;

@end
