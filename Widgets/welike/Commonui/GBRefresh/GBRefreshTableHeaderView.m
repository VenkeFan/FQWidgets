//
//  GBRefreshTableHeaderView.m
//  GBRefreshTableHeaderViewDemo
//
//  Created by 郭一博 on 12-12-12.
//  Copyright (c) 2012年 郭一博. All rights reserved.
//

#import "GBRefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>
//#import "WLLoadingView.h"
#import "WLRequestFinishAnimationView.h"
#import "WLDynamicLoadingView.h"

#define REFRESH_HEADER_HEIGHT 64.0
#define CircleViewSize 22

@implementation GBRefreshTableHeaderView {
    CGFloat _originalInsetsTop;
}

- (void)dealloc {
    

}



- (id)initWithFrame:(CGRect)frame type:(RefreshHeaderType)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height);
     
        headerType = type;

        if (type == MyInfo)
        {
             self.backgroundColor = kMainColor;
        }
        
        if (type == Normal)
        {
            self.backgroundColor = [UIColor clearColor]; // kNavbarColor;
            
            refreshArrow = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - CircleViewSize)/ 2.f,
                                                                         self.frame.size.height - CircleViewSize,
                                                                         CircleViewSize, CircleViewSize)];
//            refreshArrow.backgroundColor = [UIColor redColor];
            [self addSubview:refreshArrow];

            dynamicLoadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(0, 0, CircleViewSize, CircleViewSize)];
            dynamicLoadingView.lineWidth = 3;
            [refreshArrow addSubview:dynamicLoadingView];
            
            
            requestFinishAnimationView = [[WLRequestFinishAnimationView alloc] initWithFrame:CGRectMake((self.width - 27)/ 2.f, 0, 27, 40)];
            [self addSubview:requestFinishAnimationView];
             requestFinishAnimationView.hidden = YES;
        }
        

    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    UIScrollView *superView = (UIScrollView *)newSuperview;
    _originalInsetsTop = superView.contentInset.top;
}

-(void)GBRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (isLoading)
        return;
    isDragging = YES;
}

-(void)GBRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"1========%f",scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y >= -_originalInsetsTop)
    {
        if ([_delegate respondsToSelector:@selector(didScrollToProgress:)])
        {
            [_delegate didScrollToProgress:0];
        }
         dynamicLoadingView.strokeEnd = 0.0;
        [dynamicLoadingView stopAnimating];
    }

    if (scrollView.contentOffset.y < -_originalInsetsTop)
    {
        if (scrollView.contentOffset.y <= -17)
        {
            refreshArrow.top = self.frame.size.height + scrollView.contentOffset.y + (fabs(scrollView.contentOffset.y) + _originalInsetsTop - refreshArrow.height)/2.0;
        }
        else
        {
            refreshArrow.top = self.frame.size.height + _originalInsetsTop - refreshArrow.height;
        }
        
        requestFinishAnimationView.top =  refreshArrow.top - 8;
        
        
        
        if (isDragging)
        {
            if (scrollView.contentOffset.y <= -(REFRESH_HEADER_HEIGHT + _originalInsetsTop))
            {
                if ([_delegate respondsToSelector:@selector(didScrollToProgress:)])
                {
                    [_delegate didScrollToProgress:1];
                }
                 dynamicLoadingView.strokeEnd = 1;
            }
            else //scrollView.contentOffset.y > -REFRESH_HEADER_HEIGHT
            {
                float moveY = fabs(scrollView.contentOffset.y + _originalInsetsTop);
                CGFloat progress = moveY /( REFRESH_HEADER_HEIGHT- 4);

                if ([_delegate respondsToSelector:@selector(didScrollToProgress:)])
                {
                    [_delegate didScrollToProgress:progress];
                }
                  dynamicLoadingView.strokeEnd = progress;
            }
        }
        else //isDragging = NO
        {
            if (scrollView.contentOffset.y <= -(REFRESH_HEADER_HEIGHT + _originalInsetsTop))
            {
                if ([_delegate respondsToSelector:@selector(didScrollToProgress:)])
                {
                    [_delegate didScrollToProgress:1];
                }
                  dynamicLoadingView.strokeEnd = 0.9;
                
                if (!dynamicLoadingView.isAnimating)
                {
                    [dynamicLoadingView startAnimating];
                }
            }
            else
            {
                float moveY = fabs(scrollView.contentOffset.y + _originalInsetsTop);
                CGFloat progress = moveY /( REFRESH_HEADER_HEIGHT- 4);
                
                [dynamicLoadingView stopAnimating];

                if ([_delegate respondsToSelector:@selector(didScrollToProgress:)])
                {
                    [_delegate didScrollToProgress:progress];
                }
                  dynamicLoadingView.strokeEnd = progress;
            }

            if ([_delegate respondsToSelector:@selector(refreshDidEndScroll)])
            {
                [_delegate refreshDidEndScroll];
            }
        }
    }
    else
    {

    }
}

-(void)GBRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if (isLoading)
    {
        return;
    }

    isDragging = NO;
    if (scrollView.contentOffset.y <= (-1)*(REFRESH_HEADER_HEIGHT + _originalInsetsTop))
    {
        isLoading = YES;

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:3.3];
        scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT + _originalInsetsTop, 0, 0, 0);

       [UIView commitAnimations];

        if ([_delegate respondsToSelector:@selector(GBRefreshScrollViewStartLoading)])
        {
            [_delegate GBRefreshScrollViewStartLoading];
        }
    }
}

-(void)GBRefreshScrollViewStopLoading:(UIScrollView *)scrollView //
{
    //显示结束动画
    if (headerType == Normal)
    {
        refreshArrow.hidden = YES;
        [dynamicLoadingView stopAnimating];
        requestFinishAnimationView.hidden = NO;
        [requestFinishAnimationView startAnimation:^{
            if (self->_delegate)
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
                UIEdgeInsets tableContentInset = scrollView.contentInset;
                tableContentInset.top = self->_originalInsetsTop; // 0.0;
                scrollView.contentInset = tableContentInset;
                [UIView commitAnimations];
            }
        }];
    }
    
    if (headerType == MyInfo)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
        UIEdgeInsets tableContentInset = scrollView.contentInset;
        tableContentInset.top = _originalInsetsTop; // 0.0;
        scrollView.contentInset = tableContentInset;
        [UIView commitAnimations];
    }
    
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
     isLoading = NO;
    //都结束后scrollView滚动到初始位置
     if (headerType == Normal)
     {
         [requestFinishAnimationView initToOriginalState];
         requestFinishAnimationView.hidden = YES;
         refreshArrow.hidden = NO;
     }
}

-(void)GBRefreshScrollViewStopLoadingImmediately:(UIScrollView *)scrollView  //不调用
{
    isLoading = NO;
    UIEdgeInsets tableContentInset = scrollView.contentInset;
    tableContentInset.top = _originalInsetsTop; // 0.0;
    scrollView.contentInset = tableContentInset;
  

    refreshArrow.hidden = NO;
}

-(void)manualFresh:(UIScrollView *)scrollView //不调用
{
    isDragging = NO;
//    isLoading = NO;
    
    if (!isLoading)
    {
        [scrollView setContentOffset:CGPointMake(0, (-1)*(REFRESH_HEADER_HEIGHT+_originalInsetsTop))];
        [self GBRefreshScrollViewDidEndDragging:scrollView];
    }
}


@end
