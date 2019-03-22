//
//  GBRefreshTableHeaderView.h
//  GBRefreshTableHeaderViewDemo
//
//  Created by 郭一博 on 12-12-12.
//  Copyright (c) 2012年 郭一博. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GBRefreshTableHeaderViewDelegate <NSObject>

@optional
-(void)GBRefreshScrollViewStartLoading;

-(void)didScrollToProgress:(CGFloat)progress;

-(void)refreshDidEndScroll;

@end

typedef enum
{
    Normal = 0,
    MyInfo = 1, //用于我的详情页面
//    NewSyle  //用于测试新的下拉刷新
} RefreshHeaderType;

//@class CircleView;
//@class WLLoadingView;
@class WLDynamicLoadingView;
@class WLRequestFinishAnimationView;
@interface GBRefreshTableHeaderView : UIView
{
    UIImageView *refreshArrow; //图片标志
    BOOL isDragging;    //正在拖动状态
    BOOL isLoading;     //正在加载状态
    
    WLRequestFinishAnimationView *requestFinishAnimationView;
    
    WLDynamicLoadingView *dynamicLoadingView;
    
    RefreshHeaderType headerType;
    
    
    
}

@property (nonatomic, weak) id delegate;



- (id)initWithFrame:(CGRect)frame type:(RefreshHeaderType)type;

-(void)GBRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)GBRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
-(void)GBRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;

-(void)GBRefreshScrollViewStopLoading:(UIScrollView *)scrollView;
-(void)GBRefreshScrollViewStopLoadingImmediately:(UIScrollView *)scrollView;


-(void)manualFresh:(UIScrollView *)scrollView;


//- (void)finishRefreshAnimation;

@end
