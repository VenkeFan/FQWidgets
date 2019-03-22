//
//  WLNavigationBar.h
//  welike
//
//  Created by fan qi on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WLNavigationBarTitleAlignment) {
    WLNavigationBarTitleAlignment_Left,
    WLNavigationBarTitleAlignment_Center
};

@protocol WLNavigationBarDelegate <NSObject>

@optional
- (void)navigationBarLeftBtnDidClicked;
- (void)navigationBarRightBtnDidClicked;

@end

@interface WLNavigationBar : UIView

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIButton *leftBtn;
@property (nonatomic, strong, readonly) UIButton *rightBtn;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIView *navLine;

@property (nonatomic, strong) NSArray<UIButton *> *rightBtnArray;//按钮间无间隙
@property (nonatomic, strong) NSArray<UIButton *> *rightBtnArrayWithGap;//按钮间有个8像素的间隙


@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) WLNavigationBarTitleAlignment titleAlignment;

- (void)setLeftBtnTitle:(NSString *)title;
- (void)setLeftBtnImageName:(NSString *)imageName;
- (void)setRightBtnTitle:(NSString *)title;
- (void)setRightBtnImageName:(NSString *)imageName;


-(void)addHeadView:(NSString *)headUrl userID:(NSString *)userID  tapTarget:(id)target;

@property (nonatomic, weak) id<WLNavigationBarDelegate> delegate;

@end
