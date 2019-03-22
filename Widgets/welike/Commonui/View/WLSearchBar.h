//
//  WLSearchBar.h
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLSearchBar;

@protocol WLSearchBarDelegate <NSObject>

- (void)onClickSearchBar:(WLSearchBar *)searchBar;

@optional
- (void)onBackSearchBar:(WLSearchBar *)searchBar;

- (void)onClickRank;

@end

@interface WLSearchBar : UIView

@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL showBack;
@property (nonatomic, weak) id<WLSearchBarDelegate> delegate;

- (id)initWithIcon:(NSString *)iconResId placeholder:(NSString *)placeholder;

-(void)addRankBtn;

@end
