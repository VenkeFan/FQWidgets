//
//  WLEmoticonInputView.m
//  welike
//
//  Created by gyb on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLEmoticonInputView.h"
#import "WLEmoticonCell.h"
#import "CALayer+WLAdd.h"
#import "WLEmojiManager.h"

#define kToolbarHeight 37
#define kOnePageCount 20
#define kOneEmoticonHeight 50

@implementation WLEmoticonInputView

+ (instancetype)sharedView {
    static WLEmoticonInputView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
    });
    return v;
}

-(instancetype)init {
    self = [super init];
    self.frame = CGRectMake(0, 0, kScreenWidth, 216 - kToolbarHeight);
    self.backgroundColor = [UIColor whiteColor];
    [self initGroups];
    [self initCollectionView];
    
    _currentPageIndex = 0;
    
    return self;
}

- (void)initGroups {
    _emoticonGroupPageIndexs = [[NSMutableArray alloc] initWithObjects:@(0), nil];
    NSInteger emojiPageNum = ceil([WLEmojiManager emotionsArray].count / kOnePageCount);
    _emoticonGroupTotalPageCount = emojiPageNum;
    _emoticonGroupPageCounts =  [[NSMutableArray alloc] initWithObjects:@(emojiPageNum), nil];
}

- (void)initCollectionView {
    CGFloat itemWidth = (kScreenWidth - 10 * 2) / 7.0;
    itemWidth = round(itemWidth * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
    CGFloat padding = (kScreenWidth - 7 * itemWidth) / 2.0;
    CGFloat paddingLeft = round(padding * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
    CGFloat paddingRight = kScreenWidth - paddingLeft - itemWidth * 7;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWidth, kOneEmoticonHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, paddingLeft, 0, paddingRight);
    
    _emoticonScrollView = [[WLEmoticonScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kOneEmoticonHeight * 3) collectionViewLayout:layout];
    [_emoticonScrollView registerClass:[WLEmoticonCell class] forCellWithReuseIdentifier:@"cell"];
    _emoticonScrollView.delegate = self;
    _emoticonScrollView.dataSource = self;
    _emoticonScrollView.top = 5;
    //_emoticonScrollView.backgroundColor = [UIColor redColor];
    [self addSubview:_emoticonScrollView];
    
    _pageControl = [UIButton new];
    _pageControl.size = CGSizeMake(kScreenWidth, 20);
    _pageControl.top = _emoticonScrollView.bottom - 5;
    _pageControl.left = 0;
    [self addSubview:_pageControl];
    
    NSInteger  curGroupPageIndex = ((NSNumber *)_emoticonGroupPageIndexs[0]).integerValue, curGroupPageCount = ((NSNumber *)_emoticonGroupPageCounts[0]).integerValue;
    CGFloat dotPadding = 5, width = 6, height = 6 ,page = 0;
    CGFloat pageControlWidth = (width + 2 * dotPadding) * curGroupPageCount;

    for (NSInteger i = 0; i < curGroupPageCount; i++) {
        CALayer *layer = [CALayer layer];
        layer.size = CGSizeMake(width, height);
        layer.cornerRadius = 3;
        if (page - curGroupPageIndex == i) {
            layer.backgroundColor = kMainColor.CGColor;
        } else {
            layer.backgroundColor = kUIColorFromRGB(0xEEEEEE).CGColor;
        }
        layer.centerY = _pageControl.height / 2;
        layer.left = (_pageControl.width - pageControlWidth) / 2 + i * (width + 2 * dotPadding) + dotPadding;
        [_pageControl.layer addSublayer:layer];
    }
}



#pragma mark UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = round(scrollView.contentOffset.x / scrollView.width);
    if (page < 0) page = 0;
    else if (page >= _emoticonGroupTotalPageCount) page = _emoticonGroupTotalPageCount - 1;
    if (page == _currentPageIndex) return;
    _currentPageIndex = page;
    NSInteger curGroupIndex = 0, curGroupPageIndex = 0, curGroupPageCount = 0;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (page >= pageIndex.unsignedIntegerValue) {
            curGroupIndex = i;
            curGroupPageIndex = ((NSNumber *)_emoticonGroupPageIndexs[i]).integerValue;
            curGroupPageCount = ((NSNumber *)_emoticonGroupPageCounts[i]).integerValue;
            break;
        }
    }
    
    [_pageControl.layer removeAllSublayers];
    
    CGFloat padding = 5, width = 6, height = 6;
    CGFloat pageControlWidth = (width + 2 * padding) * curGroupPageCount;
    for (NSInteger i = 0; i < curGroupPageCount; i++) {
        CALayer *layer = [CALayer layer];
        layer.size = CGSizeMake(width, height);
        layer.cornerRadius = 3;
        if (page - curGroupPageIndex == i) {
            layer.backgroundColor = kMainColor.CGColor;
        } else {
            layer.backgroundColor = kUIColorFromRGB(0xEEEEEE).CGColor;
        }
        layer.centerY = _pageControl.height / 2;
        layer.left = (_pageControl.width - pageControlWidth) / 2 + i * (width + 2 * padding) + padding;
        [_pageControl.layer addSublayer:layer];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _emoticonGroupTotalPageCount;//1+5
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kOnePageCount + 1;//21
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WLEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == kOnePageCount) {
        cell.isDelete = YES;
        cell.emoticonStr = nil;
    } else {
        cell.isDelete = NO;
        cell.emoticonStr = [self emoticonForIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

#pragma mark - WLEmoticonScrollViewDelegate
- (void)emoticonScrollViewDidTapCell:(WLEmoticonCell *)cell
{
    //选择表情后在数据库中记录,最多纪录20个
    if (!cell) return;
    if (cell.isDelete) {
        if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
            [[UIDevice currentDevice] playInputClick];
            [self.delegate emoticonInputDidTapBackspace];
        }
    } else {
        NSString *text = cell.emoticonStr;
        if (text && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
            [self.delegate emoticonInputDidTapText:text];
        }
    }
}


//这里取:1.历史记录 2.emoji列表
- (NSString *)emoticonForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section; //0
    
    
    
        for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {  // 0  1
            NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
            if (section >= pageIndex.unsignedIntegerValue) {
                NSUInteger page = section - pageIndex.unsignedIntegerValue;
                NSUInteger index = page * kOnePageCount + indexPath.row;
                NSUInteger ip = index / kOnePageCount;
                NSUInteger ii = index % kOnePageCount;
                NSUInteger reIndex = (ii % 3) * 7 + (ii / 3);
                index = reIndex + ip * kOnePageCount;
                
                if (index < [WLEmojiManager emotionsArray].count)
                {
                    return [WLEmojiManager emotionsArray][index];
                }
                else
                {
                    return nil;
                }
            }
        }
    
    
    return nil;
}



@end
