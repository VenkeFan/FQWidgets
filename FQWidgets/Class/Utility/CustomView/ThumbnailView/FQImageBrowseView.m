//
//  FQImageBrowseView.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQImageBrowseView.h"

#define AnimateDuration         0.3

#pragma mark - ************************* FQImageBrowseItem *************************

@implementation FQImageBrowseItem

@end

#pragma mark - ************************* FQImageBrowseCell *************************

@interface FQImageBrowseCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIImageView *imgView;
@property (nonatomic, strong) FQImageBrowseItem *item;

@end

@implementation FQImageBrowseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentOffset = CGPointZero;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.zoomScale = 1.0;
        [self.contentView addSubview:_scrollView];
        
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addSubview:_imgView];
    }
    return self;
}

- (void)setItem:(FQImageBrowseItem *)item {
    _item = item;
    
    _scrollView.contentSize = CGSizeZero;
    [_scrollView setZoomScale:1.0 animated:YES];
    
    UIImage *img = nil;
    if ([item.imgURL isKindOfClass:[NSString class]]) {
        img = [UIImage imageNamed:item.imgURL];
    } else if ([item.imgURL isKindOfClass:[UIImage class]]) {
        img = (UIImage *)item.imgURL;
    }
    
    _imgView.image = img;
    
    [self p_resizeImageView];
}

#pragma mark - Private

- (void)p_resizeImageView {
    /*
     单图：比例图宽=屏宽。
     图片实际宽度>=屏宽像素时，图宽缩放至=屏幕宽度。图高按比例缩放。
         缩放后图高>屏幕高度时，顶部对齐居上显示，可上下滑动。
         缩放后图高<=屏幕高度时，上下居中显示。
     图片实际宽度<屏宽像素时，放大至屏幕宽度。图高按比例缩放。
         缩放后图高>屏幕高度时，顶部对齐居上显示，可上下滑动。
         缩放后图高<=屏幕高度时，上下居中显示。
     */
    if (!_imgView.image) {
        return;
    }
    CGSize imgSize = _imgView.image.size;
    
    CGFloat newWidth = kScreenWidth;
    CGFloat newHeight = imgSize.height / imgSize.width * newWidth;
    
    _imgView.frame = CGRectMake(0, 0, newWidth, newHeight);
    if (newHeight > kScreenHeight) {
        _scrollView.contentSize = CGSizeMake(newWidth, newHeight);
        _scrollView.contentOffset = CGPointZero;
    } else {
        _imgView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                  scrollView.contentSize.height * 0.5 + offsetY);
}

@end

#pragma mark - ************************* FQImageBrowseView *************************

static NSString * const reusCellID = @"FQImageBrowseCell";

@interface FQImageBrowseView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation FQImageBrowseView

- (instancetype)initWithItemArray:(NSArray<FQImageBrowseItem *> *)itemArry {
    if (itemArry.count == 0) {
        return nil;
    }
    
    if (self = [super init]) {
        _itemArray = itemArry;
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.alpha = 0.0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTap:)];
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                   action:@selector(selfOnLongPressed:)];
        [self addGestureRecognizer:longPress];
        
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
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:fromFrame];
//    tmpView.layer.contents = fromView.layer.contents;
//    tmpView.layer.contentsGravity = kCAGravityResizeAspect;
    tmpView.image = fromView.image;
    tmpView.contentMode = UIViewContentModeScaleAspectFit;
    tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tmpView];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^{
                         tmpView.frame = self.frame;
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self p_layoutScrollViewWithFromView:fromView];
                         [tmpView removeFromSuperview];
                     }];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQImageBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    [cell setItem:_itemArray[indexPath.row]];
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

- (void)selfOnTap:(UITapGestureRecognizer *)gesture {
    if (self.pageControl.currentPage >= _itemArray.count) {
        return;
    }
    
    FQImageBrowseCell *cell = (FQImageBrowseCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
    if (!cell) {
        return;
    }
    
    UIView *fromView = cell.imgView;
    UIView *toView = _itemArray[self.pageControl.currentPage].thumbView;
    CGRect toFrame = [toView convertRect:toView.bounds toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^(){
                         cell.scrollView.zoomScale > cell.scrollView.minimumZoomScale
                         ? [cell.scrollView setZoomScale:cell.scrollView.minimumZoomScale]
                         : nil;
                         
                         fromView.frame = toFrame;
                         self.contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

- (void)selfOnDoubleTap:(UITapGestureRecognizer *)gesture {
    FQImageBrowseCell *cell = (FQImageBrowseCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
    if (!cell) {
        return;
    }
    if (cell.scrollView.zoomScale > cell.scrollView.minimumZoomScale) {
        [cell.scrollView setZoomScale:cell.scrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat maxZoomScale = cell.scrollView.maximumZoomScale;
        CGPoint point = [gesture locationInView:cell.imgView];

        CGFloat newWidth = self.frame.size.width / maxZoomScale;
        CGFloat newHeight = self.frame.size.height / maxZoomScale;

        CGFloat newX = point.x - newWidth / 2;
        CGFloat newY = point.y - newHeight / 2;

        [cell.scrollView zoomToRect:CGRectMake(newX, newY, newWidth, newHeight) animated:YES];
    }
}

- (void)selfOnPan:(UIPanGestureRecognizer *)gesture {
    CGFloat marginalValue = 100.0; // 临界值
    
    UIView *rootView = ([UIApplication sharedApplication].keyWindow.rootViewController).view;
    CGPoint translation = [gesture translationInView:rootView];
    
    int translationY = abs((int)translation.y);
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.pageControl.hidden = YES;
        
        CGFloat floatValue = (marginalValue-translationY)/marginalValue;
        
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

- (void)selfOnLongPressed:(UILongPressGestureRecognizer *)gesture {
//    UIImageView *imgView = (UIImageView *)gesture.view;
//    UIImage *img = imgView.image;
//    if (img) {
//        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }
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

// 保存完毕回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    
    if(error != NULL)
        msg = @"保存图片失败";
    else
        msg = @"保存图片成功";
    NSLog(@"%@", msg);
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
