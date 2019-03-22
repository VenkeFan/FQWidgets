//
//  WLScrollViewCell.h
//  welike
//
//  Created by fan qi on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+FQEmptyData.h"
#import "WLBasicTableView.h"

@class WLScrollViewCell, WLScrollContentView;

@protocol WLScrollViewCellDelegate <NSObject>

- (void)userDetailCellHorizontalScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)userDetailCellHorizontalScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@protocol WLScrollContentViewProtocol <NSObject>

@property (nonatomic, weak) WLScrollViewCell *superCell;
@property (nonatomic, assign) BOOL hasRefreshed;
- (void)refreshData;
- (void)forceRefresh;

@optional
- (void)reloadMyData;
- (void)setContentOffset:(CGPoint)offset;

@end

@interface WLScrollViewCell : UITableViewCell

@property (nonatomic, weak) id<WLScrollViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL superScrollViewScrolling;
@property (nonatomic, assign) BOOL subScrollViewScrolling;

@property (nonatomic, copy) NSArray<id<WLScrollContentViewProtocol>> *subViews;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)forceRefresh;

@end


@interface WLScrollContentView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource, WLScrollContentViewProtocol>

@property (nonatomic, strong) WLBasicTableView *tableView;

@end
