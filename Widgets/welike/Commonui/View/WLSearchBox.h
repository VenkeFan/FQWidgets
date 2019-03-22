//
//  WLSearchBox.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLSearchBox;

@protocol WLSearchBoxDelegate <NSObject>

@optional
- (void)onClickRightButton:(WLSearchBox *)searchBox;

@end

@interface WLSearchBox : UIView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *leftIconResId;
@property (nonatomic, copy) NSString *rightBtnTitle;
@property (nonatomic, readonly) UITextField *searchTextField;
@property (nonatomic , weak) id<WLSearchBoxDelegate> delegate;

@end
