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

@property (nonatomic, strong) NSMutableArray *mutDataArray;

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
    for (WLFeedModel *status in item.statuses) {
        [self.mutDataArray addObject:status];
    }
    
    if (finished) {
        finished(YES, _pageIndex < _totalPage);
    }
}

#pragma mark - Getter

- (NSMutableArray *)mutDataArray {
    if (!_mutDataArray) {
        _mutDataArray = [NSMutableArray array];
    }
    return _mutDataArray;
}

- (NSArray *)dataArray {
    return self.mutDataArray;
}

@end
