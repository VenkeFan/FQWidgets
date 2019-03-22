//
//  WLBasicTableView+WLTracker.m
//  welike
//
//  Created by fan qi on 2018/11/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBasicTableView+WLTracker.h"
#import "WLFeedCell.h"
#import "WLTrackerPostDisplay.h"
#import "WLTrackerPostRead.h"
#import "WLFeedLayout.h"

static CGFloat lastOffsetY = 0.0;
static NSIndexPath *lastIndexPath = nil;

static WLFeedCell *readingCell = nil;
static CFTimeInterval beginTime = 0.0;
static CFTimeInterval endTime = 0.0;

@implementation WLBasicTableView (WLTracker)

+ (void)load {
    swizzleInstanceMethod(self, @selector(scrollViewWillBeginDragging:), @selector(swizzle_scrollViewWillBeginDragging:));
    swizzleInstanceMethod(self, @selector(scrollViewDidEndDecelerating:), @selector(swizzle_scrollViewDidEndDecelerating:));
    swizzleInstanceMethod(self, @selector(scrollViewDidEndDragging:willDecelerate:), @selector(swizzle_scrollViewDidEndDragging:willDecelerate:));
}

#pragma mark - Swizzle-Method

- (void)swizzle_scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self swizzle_scrollViewWillBeginDragging:scrollView];
    
    beginTime = CACurrentMediaTime();
    [self p_appendReadTracker];
}

- (void)swizzle_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self swizzle_scrollViewDidEndDecelerating:scrollView];
    
    endTime = CACurrentMediaTime();
    
    [self p_getDisplayedCellWithCurrentOffsetY:scrollView.contentOffset.y];
    [self p_getReadingCell];
}

- (void)swizzle_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self swizzle_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if (!decelerate) {
        endTime = CACurrentMediaTime();
        
        [self p_getDisplayedCellWithCurrentOffsetY:scrollView.contentOffset.y];
        [self p_getReadingCell];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

#pragma mark - Displayed dotting

- (void)p_getDisplayedCellWithCurrentOffsetY:(CGFloat)currentOffsetY {
    id array = nil;
    
    if ([[AppContext currentViewController] isKindOfClass:NSClassFromString(@"WLSearchResultViewController")]) {
        array = [[AppContext currentViewController] valueForKeyPath:@"dataArray"];
    } else {
        array = [self valueForKeyPath:@"dataArray"];
    }
    
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray *dataArray = (NSArray *)array;
    
    BOOL isDisplayMore = NO;
    if (currentOffsetY > lastOffsetY) {
        isDisplayMore = YES;
    } else {
        isDisplayMore = NO;
    }
    lastOffsetY = currentOffsetY;
    
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:CGPointMake(0, currentOffsetY)];
    NSInteger sourceCount = dataArray.count; // [self p_ItemsCount];
    if (currentIndexPath.row >= sourceCount) {
        return;
    }
    
    NSInteger lastIndex = lastIndexPath ? lastIndexPath.row : 0;
    if (lastIndex >= sourceCount) {
        return;
    }
    
    if (isDisplayMore) {
        for ( ; lastIndex < currentIndexPath.row; lastIndex++) {
            id obj = dataArray[lastIndex];
            if ([obj isKindOfClass:[WLFeedLayout class]]) {
                WLFeedLayout *layout = (WLFeedLayout *)obj;
                [WLTrackerPostDisplay addDisplayedPost:layout.feedModel];
            }
        }
    } else {
        for ( ; lastIndex > currentIndexPath.row; lastIndex--) {
            id obj = dataArray[lastIndex];
            if ([obj isKindOfClass:[WLFeedLayout class]]) {
                WLFeedLayout *layout = (WLFeedLayout *)obj;
                [WLTrackerPostDisplay addDisplayedPost:layout.feedModel];
            }
        }
    }
    lastIndexPath = currentIndexPath;
    
    [WLTrackerPostDisplay appendTrackerWithDisplayAction:WLTrackerPostDisplayAction_Feed];
}

#pragma mark - Reading dotting

- (void)p_getReadingCell {
    readingCell = nil;
    
    [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLFeedCell class]]) {
            WLFeedCell *feedCell = (WLFeedCell *)obj;
            
            CGRect frame = [feedCell.feedView convertRect:feedCell.feedView.bounds
                                                   toView:kCurrentWindow];
            if (CGRectGetMinY(frame) > kNavBarHeight && CGRectGetMaxY(frame) <= (CGRectGetHeight(self.frame) + kNavBarHeight)) {
                readingCell = feedCell;
                *stop = YES;
            }
        }
    }];
    
    if (!readingCell) {
        [self.visibleCells enumerateObjectsWithOptions:NSEnumerationReverse
                                            usingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                if ([obj isKindOfClass:[WLFeedCell class]]) {
                                                    readingCell = obj;
                                                    *stop = YES;
                                                }
                                            }];
    }
}

- (void)p_appendReadTracker {
    CFTimeInterval duration = beginTime - endTime;
    if (duration >= kWLTrackerPostReadDuration && readingCell && [readingCell isKindOfClass:[WLFeedCell class]]) {
        [WLTrackerPostRead appendTrackerWithReadAction:WLTrackerPostReadAction_Feed
                                                  post:readingCell.layout.feedModel
                                              duration:duration];
    }
}

#pragma mark - Private

- (NSInteger)p_ItemsCount {
    NSInteger count = 0;
    
    if (![self respondsToSelector:@selector(dataSource)]) {
        return count;
    }
    
    NSInteger sections = 1;
    
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        
        if ([tableView.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [tableView.dataSource numberOfSectionsInTableView:tableView];
        }
        
        if ([tableView.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger i = 0; i < sections; i++) {
                count += [tableView.dataSource tableView:tableView numberOfRowsInSection:i];
            }
        }
    }
    
    return count;
}

@end
