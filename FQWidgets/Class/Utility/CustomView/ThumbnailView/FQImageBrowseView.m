//
//  FQImageBrowseView.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQImageBrowseView.h"
#import "FQZoomScaleView.h"
#import "WLFeedModel.h"

#define AnimateDuration         0.3

#pragma mark - ************************* FQImageBrowseItemModel *************************

@implementation FQImageBrowseItemModel

@end

#pragma mark - ************************* FQImageBrowseCell *************************

@class FQImageBrowseCell;
@protocol FQImageBrowseCellDelegate <NSObject>

- (void)imageBrowseCellDidTapped:(FQImageBrowseCell *)cell;

@end

@interface FQImageBrowseCell : UICollectionViewCell <FQZoomScaleViewDelegate>

@property (nonatomic, strong, readonly) FQZoomScaleView *scaleView;
@property (nonatomic, strong) FQImageBrowseItemModel *item;
@property (nonatomic, weak) id<FQImageBrowseCellDelegate> delegate;

@end

@implementation FQImageBrowseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scaleView = [[FQZoomScaleView alloc] initWithFrame:self.bounds];
        _scaleView.zoomScaleDelegate = self;
        [self.contentView addSubview:_scaleView];
    }
    return self;
}

- (void)setItem:(FQImageBrowseItemModel *)item {
    _item = item;
    
    [_scaleView setImageWithUrlString:item.imageInfo.large.url.absoluteString
                          placeholder:item.thumbView.image
                            imageSize:CGSizeMake(item.imageInfo.large.width, item.imageInfo.large.height)];
}

#pragma mark - FQZoomScaleViewDelegate

- (void)zoomScaleViewDidTapped:(FQZoomScaleView *)scaleView {
    if ([self.delegate respondsToSelector:@selector(imageBrowseCellDidTapped:)]) {
        [self.delegate imageBrowseCellDidTapped:self];
    }
}

@end

#pragma mark - ************************* FQImageBrowseView *************************

static NSString * const reusCellID = @"FQImageBrowseCell";

@interface FQImageBrowseView () <FQImageBrowseCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation FQImageBrowseView

- (instancetype)initWithItemArray:(NSArray<FQImageBrowseItemModel *> *)itemArry {
    if (itemArry.count == 0) {
        return nil;
    }
    
    if (self = [super init]) {
        _itemArray = itemArry;
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.alpha = 0.0;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnPan:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - Public

- (void)displayWithFromView:(UIImageView *)fromView toView:(UIView *)toView {
    if (!toView || !fromView || ![fromView isKindOfClass:[UIImageView class]]) {
        return;
    }
    [toView addSubview:self];
    
    CGRect fromFrame = [fromView convertRect:fromView.bounds toView:toView];
    
    UIImage *image = fromView.image;
    CGFloat newWidth = CGRectGetWidth(self.frame);
    CGFloat newHeight = image.size.height / image.size.width * newWidth;
    CGFloat originY = kStatusBarHeight;
    if (newHeight < CGRectGetHeight(self.frame)) {
        newHeight = CGRectGetHeight(self.frame);
        originY = 0;
    }
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:fromFrame];
    tmpView.image = image;
    tmpView.contentMode = UIViewContentModeScaleAspectFit;
    tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tmpView];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^{
                         tmpView.frame = (CGRect){.origin = CGPointMake(0, originY), .size = CGSizeMake(newWidth, newHeight)};
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self p_layoutScrollViewWithFromView:fromView];
                         [tmpView removeFromSuperview];
                     }];
}

#pragma mark - FQImageBrowseCellDelegate

- (void)imageBrowseCellDidTapped:(FQImageBrowseCell *)cell {
    if (self.pageControl.currentPage >= _itemArray.count) {
        return;
    }
    
    UIView *fromView = cell.scaleView.imageView;
    UIView *toView = _itemArray[self.pageControl.currentPage].thumbView;
    CGRect toFrame = [toView convertRect:toView.bounds toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^(){
                         cell.scaleView.zoomScale > cell.scaleView.minimumZoomScale
                         ? [cell.scaleView setZoomScale:cell.scaleView.minimumZoomScale]
                         : nil;
                         cell.scaleView.contentOffset = CGPointZero;
                         
                         fromView.frame = toFrame;
                         self.contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];

}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQImageBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    [cell setItem:_itemArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    CGPoint offset = scrollView.contentOffset;
    int pageIndex = ceil((offset.x - pageWidth / 2) / pageWidth);
    
    self.pageControl.currentPage = pageIndex;
}

#pragma mark - Event

- (void)selfOnPan:(UIPanGestureRecognizer *)gesture {
    CGFloat marginalValue = 100.0; // 临界值
    
    UIView *rootView = ([UIApplication sharedApplication].keyWindow.rootViewController).view;
    CGPoint translation = [gesture translationInView:rootView];
    
    int translationY = abs((int)translation.y);
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.pageControl.hidden = YES;
        
        CGFloat floatValue = (marginalValue - translationY) / marginalValue;
        if (floatValue <= 0.7) {
            floatValue = 0.7;
        }
        self.collectionView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(floatValue, floatValue), 0, translation.y);
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:floatValue];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (translationY >= marginalValue) {
            [self p_dismissWithTranslationY:translation.y];
        } else {
            self.pageControl.hidden = NO;
            
            [UIView animateWithDuration:AnimateDuration
                             animations:^(){
                                 self.collectionView.transform = CGAffineTransformIdentity;
                                 self.contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
    }
}

#pragma mark - Private

- (void)p_layoutScrollViewWithFromView:(UIView *)fromView {
    NSInteger currentIndex = 0;
    for (int i = 0; i < _itemArray.count; i++) {
        if ([fromView isEqual:_itemArray[i].thumbView]) {
            currentIndex = i;
        }
    }
    
    self.collectionView.contentOffset = CGPointMake(currentIndex * kScreenWidth, 0);
    [self.collectionView reloadData];
    
    self.pageControl.numberOfPages = _itemArray.count;
    self.pageControl.currentPage = currentIndex;
}

- (void)p_dismissWithTranslationY:(CGFloat)translationY {
    [UIView animateWithDuration:AnimateDuration
                     animations:^(){
                         if(translationY > 0) {
                             self.collectionView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.collectionView.transform.a, self.collectionView.transform.a),
                                                                                        0, kScreenHeight);
                         } else {
                             self.collectionView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.collectionView.transform.a, self.collectionView.transform.a),
                                                                                        0, -kScreenHeight);
                         }
                         
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        _contentView = view;
    }
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        collView.backgroundColor = [UIColor clearColor];
        collView.delegate = self;
        collView.dataSource = self;
        collView.pagingEnabled = YES;
        collView.showsHorizontalScrollIndicator = NO;
        collView.showsVerticalScrollIndicator = NO;
        [collView registerClass:[FQImageBrowseCell class] forCellWithReuseIdentifier:reusCellID];
        collView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:collView];
        _collectionView = collView;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageCtr = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight - kSafeAreaBottomY - 30,
                                                                                 kScreenWidth, 30)];
        pageCtr.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageCtr.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        pageCtr.hidesForSinglePage = YES;
        [self.contentView addSubview:pageCtr];
        _pageControl = pageCtr;
    }
    return _pageControl;
}

@end
