//
//  WLTimelineViewModel.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLTimelineViewModel.h"

@interface WLTimelineViewModel () {
    NSInteger _totalPage;
    NSInteger _pageIndex;
    
    BOOL _hasMore;
}

@property (nonatomic, strong) NSMutableArray<WLFeedModel *> *mutDataArray;

@end

@implementation WLTimelineViewModel

- (instancetype)init {
    if (self = [super init]) {
        _pageIndex = 1;
    }
    return self;
}

#pragma mark - Public

- (void)fetchListWithFinished:(void (^)(BOOL succeed, BOOL hasMore))finished {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _pageIndex = 1;
        [self p_fetchListWithPageIndex:_pageIndex finished:finished];
    });
}

- (void)fetchMoreWithFinished:(void (^)(BOOL succeed, BOOL hasMore))finished {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (++_pageIndex <= _totalPage) {
            [self p_fetchListWithPageIndex:_pageIndex finished:finished];
        } else {
            if (finished) {
                finished(NO, NO);
            }
        }
    });
}

#pragma mark - Private

- (void)p_fetchListWithPageIndex:(NSInteger)pageIndex finished:(void(^)(BOOL succeed, BOOL hasMore))finished {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"weibo_%zd.json", pageIndex - 1] ofType:nil];
    if (!filePath) {
        if (finished) {
            finished(NO, NO);
        }
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    _totalPage = 8;
    if (_pageIndex == 1) {
        [self.mutDataArray removeAllObjects];
    }
    
    WLTimelineItem *item = [WLTimelineItem modelWithJSON:data];
    for (WLFeedModel *feedModel in item.statuses) {
        [self p_layoutFeedContentWithFeedModel:feedModel];
        [self.mutDataArray addObject:feedModel];
    }
    
    if (finished) {
        finished(YES, _pageIndex < _totalPage);
    }
}

#pragma mark - Layout

- (void)p_layoutFeedContentWithFeedModel:(WLFeedModel *)feedModel {
    CGFloat y = 0;
    CGFloat width = kScreenWidth - cellPaddingLeft * 2;
    
    CGFloat profileHeight = [self p_layoutProfileWithFeedModel:feedModel width:width];
    feedModel.layout.profileFrame = CGRectMake(0, 0, width, profileHeight);
    y += CGRectGetHeight(feedModel.layout.profileFrame);
    
    CGFloat textHeight = [self p_layoutText:feedModel.text width:width];
    feedModel.layout.textHeight = textHeight;
    y += textHeight;
    
    if (feedModel.pageInfo) {
        y += cellCardHeight;
    }
    
    feedModel.layout.contentFrame = CGRectMake(cellPaddingLeft, cellPaddingTop, width, y);
    feedModel.layout.cellHeight = CGRectGetMaxY(feedModel.layout.contentFrame) + cellToolBarHeight + cellMarginY;
}

- (CGFloat)p_layoutProfileWithFeedModel:(WLFeedModel *)feedModel width:(CGFloat)width {
    CGFloat x = cellAvatarSize + cellPaddingX;
    CGFloat y = kSizeScale(5);
    
    CGFloat nameHeight = [feedModel.user.screenName sizeWithAttributes:@{NSFontAttributeName: cellNameFont}].height;
    CGRect nameFrame = CGRectMake(x, y, width - x, nameHeight);
    y += (nameHeight + kSizeScale(2));
    
    CGFloat timeHeight = [feedModel.source sizeWithAttributes:@{NSFontAttributeName: cellDateTimeFont}].height;
    CGRect timeFrame = CGRectMake(x, y, CGRectGetWidth(nameFrame), timeHeight);
    
    feedModel.layout.nameFrame = nameFrame;
    feedModel.layout.timeFrame = timeFrame;
    
    return cellAvatarSize;
}

- (CGFloat)p_layoutText:(NSString *)text width:(CGFloat)width {
    CGFloat height = [text boundingRectWithSize:CGSizeMake(width, kScreenHeight)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: cellBodyFont}
                                        context:nil].size.height;
    
    return height;
}

#pragma mark - Getter

- (NSMutableArray<WLFeedModel *> *)mutDataArray {
    if (!_mutDataArray) {
        _mutDataArray = [NSMutableArray array];
    }
    return _mutDataArray;
}

- (NSArray<WLFeedModel *> *)dataArray {
    return self.mutDataArray;
}

@end
