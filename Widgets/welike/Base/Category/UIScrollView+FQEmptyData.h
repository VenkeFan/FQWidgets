//
//  UIScrollView+FQEmptyData.h
//  welike
//
//  Created by fan qi on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultEmptyTop        (30.0)

typedef NS_ENUM(NSInteger, WLScrollEmptyType) {
    WLScrollEmptyType_None = 0,
    WLScrollEmptyType_Empty_Data,
    WLScrollEmptyType_Empty_Relationship,
    WLScrollEmptyType_Empty_Message,
    WLScrollEmptyType_Empty_Deleted,
    WLScrollEmptyType_Empty_Network,
    WLScrollEmptyType_Empty_Location,
    WLScrollEmptyType_Empty_Topic
};

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

@interface UIScrollView (FQEmptyData)

@property (nonatomic, weak) id<UIScrollViewEmptyDelegate> emptyDelegate;
@property (nonatomic, weak) id<UIScrollViewEmptyDataSource> emptyDataSource;

@property (nonatomic, assign) CGFloat emptyTop;

@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (nonatomic, assign) BOOL displayEmptyImage;
@property (nonatomic, assign) WLScrollEmptyType emptyType;

- (void)reloadEmptyData;

@end
