//
//  FQBadgeView.h
//  chongchongtv
//
//  Created by fanqi on 2017/8/8.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQBadgeView : UIView

- (instancetype)initWithParentView:(UIView *)parentView;

@property (nonatomic, assign) NSInteger badgeNumber;
@property (nonatomic, assign) CGPoint badgePosition;

@property (nonatomic, assign) CGFloat adjustX;
@property (nonatomic, assign) CGFloat adjustY;

@end
