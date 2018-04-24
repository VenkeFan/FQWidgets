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
    
    [self p_layoutProfileWithFeedModel:feedModel];
    y += (feedModel.layout.profileHeight + cellPaddingY);
    
    [self p_layoutTextWithFeedModel:feedModel];
    feedModel.layout.textTop = y;
    y += (feedModel.layout.textHeight + cellPaddingY);
    
    if (feedModel.retweetedStatus) {
        y -= cellPaddingY;
        [self p_layoutRetweeted:feedModel];
        feedModel.layout.retweetedViewTop = y;
        feedModel.retweetedStatus.layout.retweetedTextTop = y + cellPaddingY;
        feedModel.retweetedStatus.layout.picGroupTop = feedModel.retweetedStatus.layout.retweetedTextTop + feedModel.retweetedStatus.layout.retweetedTextHeight + cellPaddingY;
        feedModel.retweetedStatus.layout.cardTop = feedModel.retweetedStatus.layout.picGroupTop;
        y += feedModel.layout.retweetedViewHeight;
        
    } else if (feedModel.pics.count > 0) {
        [self p_layoutPictures:feedModel];
        feedModel.layout.picGroupTop = y;
        y += (feedModel.layout.picGroupSize.height + cellPaddingY);
        
    } else if (feedModel.pageInfo) {
        feedModel.layout.cardTop = y;
        y += (cellCardHeight + cellPaddingY);
    }
    
    feedModel.layout.contentHeight = y;
    feedModel.layout.cellHeight = cellPaddingTop + feedModel.layout.contentHeight + cellToolBarHeight + cellMarginY;
}

- (void)p_layoutProfileWithFeedModel:(WLFeedModel *)feedModel {
    CGFloat x = cellAvatarSize + cellPaddingX;
    CGFloat y = kSizeScale(5);
    
    CGFloat nameHeight = [feedModel.user.screenName sizeWithAttributes:@{NSFontAttributeName: cellNameFont}].height;
    CGRect nameFrame = CGRectMake(x, y, cellContentWidth - x, nameHeight);
    y += (nameHeight + kSizeScale(2));
    
    CGFloat timeHeight = [feedModel.source sizeWithAttributes:@{NSFontAttributeName: cellDateTimeFont}].height;
    CGRect timeFrame = CGRectMake(x, y, CGRectGetWidth(nameFrame), timeHeight);
    
    feedModel.layout.nameFrame = nameFrame;
    feedModel.layout.timeFrame = timeFrame;
    feedModel.layout.profileHeight = cellAvatarSize;
}

- (void)p_layoutTextWithFeedModel:(WLFeedModel *)feedModel {
    CGFloat height = [feedModel.text boundingRectWithSize:CGSizeMake(cellContentWidth, kScreenHeight)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName: cellBodyFont}
                                                  context:nil].size.height;
    feedModel.layout.textHeight = height;
}

- (void)p_layoutPictures:(WLFeedModel *)feedModel {
    if (feedModel.pics.count == 0) {
        feedModel.layout.picSize = feedModel.layout.picGroupSize = CGSizeZero;
        return;
    }
    
    if (feedModel.pics.count == 1) {
        WLPicture *pic = feedModel.pics.firstObject;
        CGSize newSize = CGSizeMake(pic.bmiddle.width, pic.bmiddle.height);
        
        CGFloat ratio = pic.bmiddle.width / (float)pic.bmiddle.height;
        if (ratio <= 1.01 && ratio >= 0.99) {
            // 方图
            CGFloat squareWidth = cellContentWidth * 2 / 3.0;
            newSize = CGSizeMake(squareWidth, squareWidth);
        } else if (ratio > 1.01) {
            // 宽图
            CGFloat width = cellContentWidth * 2 / 3.0;
            CGFloat height = cellContentWidth * 0.5;
            newSize = CGSizeMake(width, height);
        } else {
            // 长图
            CGFloat width = cellContentWidth * 0.5;
            CGFloat height = cellContentWidth * 2 / 3.0;
            newSize = CGSizeMake(width, height);
        }
        
        feedModel.layout.picSize = feedModel.layout.picGroupSize = newSize;
        return;
    }
    
    NSInteger numberInRow = 3;
    CGFloat picWidth = cellContentWidth / numberInRow - (numberInRow - 1) * cellPicSpacing;
    
    if (feedModel.pics.count == 4) {
        numberInRow = 2;
    }
    
    CGFloat totalWidth = feedModel.pics.count >= numberInRow
    ? numberInRow * (picWidth + cellPicSpacing) - cellPicSpacing
    : feedModel.pics.count * (picWidth + cellPicSpacing) - cellPicSpacing;
    
    CGFloat totalHeight = ceilf((feedModel.pics.count / (float)numberInRow)) * (picWidth + cellPicSpacing) - cellPicSpacing;
    
    feedModel.layout.picSize = CGSizeMake(picWidth, picWidth);
    feedModel.layout.picGroupSize = CGSizeMake(totalWidth, totalHeight);
}

- (void)p_layoutRetweeted:(WLFeedModel *)feedModel {
    CGFloat height = 0;
    [self p_layoutRetweetedText:feedModel.retweetedStatus];
    height += (feedModel.retweetedStatus.layout.retweetedTextHeight + cellPaddingY);
    
    if (feedModel.retweetedStatus.pics.count > 0) {
        [self p_layoutRetweetedPics:feedModel.retweetedStatus];
        height += (feedModel.retweetedStatus.layout.picGroupSize.height + cellPaddingY);
    } else if (feedModel.retweetedStatus.pageInfo) {
        height += (cellCardHeight + cellPaddingY);
    }
    
    feedModel.layout.retweetedViewHeight = height + cellPaddingY;
}

- (void)p_layoutRetweetedText:(WLFeedModel *)feedModel {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@", feedModel.user.screenName] attributes:@{NSForegroundColorAttributeName: kLinkFontColor}];
    
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@":%@", feedModel.text]
                                                                    attributes:@{NSForegroundColorAttributeName: kBodyFontColor}]];
    
    [attrStr addAttributes:@{NSFontAttributeName: cellBodyFont} range:NSMakeRange(0, attrStr.string.length)];
    
    CGFloat height = [attrStr boundingRectWithSize:CGSizeMake(cellContentWidth, kScreenHeight)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil].size.height;
    feedModel.layout.retweetedTextHeight = height;
    feedModel.layout.retweetedText = attrStr;
}

- (void)p_layoutRetweetedPics:(WLFeedModel *)feedModel {
    [self p_layoutPictures:feedModel];
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
