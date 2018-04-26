//
//  UIScrollView+FQExtension.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/26.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIScrollViewEmptyDelegate <NSObject>

@optional
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView;

@end

@protocol UIScrollViewEmptyDataSource <NSObject>

@optional
- (UIImage *)imageForEmptyDataSource:(UIScrollView *)scrollView;
- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView;
- (NSString *)buttonTitleForEmptyDataSource:(UIScrollView *)scrollView;

@end

@interface UIScrollView (FQExtension)

@property (nonatomic, weak) id<UIScrollViewEmptyDelegate> emptyDelegate;
@property (nonatomic, weak) id<UIScrollViewEmptyDataSource> emptyDataSource;

- (void)reloadEmptyData;

@end
