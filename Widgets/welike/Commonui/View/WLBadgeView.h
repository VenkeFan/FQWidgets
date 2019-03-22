//
//  WLBadgeView.h
//  chongchongtv
//
//  Created by fanqi on 2017/8/8.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WLBadgeViewType) {
    WLBadgeViewType_Normal,
    WLBadgeViewType_Number
};

@interface WLBadgeView : UIView

- (instancetype)init __attribute__((unavailable));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));

- (instancetype)initWithParentView:(UIView *)parentView size:(CGFloat)size fontSize:(CGFloat)fontSize;
- (instancetype)initWithParentView:(UIView *)parentView;
- (instancetype)initWithSize:(CGFloat)size fontSize:(CGFloat)fontSize;

@property (nonatomic, assign) NSInteger badgeNumber;

@property (nonatomic, assign) CGFloat adjustX;
@property (nonatomic, assign) CGFloat adjustY;

@property (nonatomic, assign) WLBadgeViewType badgeType;

@end
