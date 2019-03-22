//
//  WLImageBrowseView.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLImageBrowseView.h"
#import "WLZoomScaleView.h"
#import "WLPicInfo.h"
#import "WLAlertController.h"
#import "WLTrackerActivity.h"

#define AnimateDuration         0.3
#define kMaxPageNumbers         9

#pragma mark - ************************* FQImageBrowseItemModel *************************

@implementation FQImageBrowseItemModel

@end

#pragma mark - ************************* FQImageBrowseCell *************************

@class FQImageBrowseCell;
@protocol FQImageBrowseCellDelegate <NSObject>

- (void)imageBrowseCellDidTapped:(FQImageBrowseCell *)cell;

@end

@interface FQImageBrowseCell : UICollectionViewCell <WLZoomScaleViewDelegate>

@property (nonatomic, strong, readonly) WLZoomScaleView *scaleView;
@property (nonatomic, strong) FQImageBrowseItemModel *item;
@property (nonatomic, weak) id<FQImageBrowseCellDelegate> delegate;

@end

@implementation FQImageBrowseCell

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scaleView = [[WLZoomScaleView alloc] initWithFrame:self.bounds];
        _scaleView.zoomScaleDelegate = self;
        [self.contentView addSubview:_scaleView];
    }
    return self;
}

#pragma mark - Public

- (void)setItem:(FQImageBrowseItemModel *)item useCache:(BOOL)useCache {
    _item = item;
    
    _scaleView.useCache = useCache;
    _scaleView.userName = item.userName;
    [_scaleView setImageWithUrlString:item.imageInfo.picUrl
                          placeholder:item.thumbView.image
                            imageSize:CGSizeMake(item.imageInfo.width, item.imageInfo.height)];
}

#pragma mark - WLZoomScaleViewDelegate

- (void)zoomScaleViewDidTapped:(WLZoomScaleView *)scaleView {
    if ([self.delegate respondsToSelector:@selector(imageBrowseCellDidTapped:)]) {
        [self.delegate imageBrowseCellDidTapped:self];
    }
}

@end

#pragma mark - ************************* WLImageBrowseView *************************

static NSString * const reusCellID = @"FQImageBrowseCell";

@interface WLImageBrowseView () <FQImageBrowseCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, copy) NSArray<FQImageBrowseItemModel *> *itemArray;

@end

@implementation WLImageBrowseView {
    BOOL _isPressed;
    
    CFTimeInterval beginTime;
    CFTimeInterval endTime;
}

#pragma mark - LifeCycle

- (instancetype)initWithItemArray:(NSArray<FQImageBrowseItemModel *> *)itemArry {
    if (itemArry.count == 0) {
        return nil;
    }
    
    if (self = [super init]) {
        _itemArray = itemArry;
        

        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.alpha = 0.0;
        
        _useCache = YES;
        _isPressed = NO;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnPan:)];
        [self addGestureRecognizer:panGesture];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                   action:@selector(selfOnLongPressed:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Public

- (void)displayWithFromView:(UIImageView *)fromView toView:(UIView *)toView {
    if (!toView || !fromView || ![fromView isKindOfClass:[UIImageView class]]) {
        return;
    }
    [toView addSubview:self];
    
    CGRect fromFrame = [fromView convertRect:fromView.bounds toView:toView];
    
    UIImage *image = fromView.image;
    if (!image) {
        return;
    }
    
    CGFloat newWidth = CGRectGetWidth(self.frame);
    CGFloat newHeight = image.size.height / image.size.width * newWidth;
    CGFloat originY = kSystemStatusBarHeight;
    if (newHeight < CGRectGetHeight(self.frame)) {
        newHeight = CGRectGetHeight(self.frame);
        originY = 0;
    }
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:fromFrame];
    tmpView.image = image;
    if (image.isPlaceholder) {
        tmpView.contentMode = UIViewContentModeCenter;
    } else {
        tmpView.contentMode = UIViewContentModeScaleAspectFit;
    }
    tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tmpView];
    
    [[AppContext currentViewController] setStatusBarHidden:YES];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^{
                         tmpView.frame = (CGRect){.origin = CGPointMake(0, originY), .size = CGSizeMake(newWidth, newHeight)};
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self p_layoutScrollViewWithFromView:fromView y:originY];
                         [tmpView removeFromSuperview];
                     }];
    
    [self p_trackerAppear];
}

- (void)displayWithFromBtn:(UIButton *)fromView toView:(UIView *)toView {
    if (!toView || !fromView || ![fromView isKindOfClass:[UIImageView class]]) {
        return;
    }
    [toView addSubview:self];
    
    CGRect fromFrame = [fromView convertRect:fromView.bounds toView:toView];
    
    UIImage *image = fromView.imageView.image;
    if (!image) {
        return;
    }
    
    CGFloat newWidth = CGRectGetWidth(self.frame);
    CGFloat newHeight = image.size.height / image.size.width * newWidth;
    CGFloat originY = kSystemStatusBarHeight;
    if (newHeight < CGRectGetHeight(self.frame)) {
        newHeight = CGRectGetHeight(self.frame);
        originY = 0;
    }
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:fromFrame];
    tmpView.image = image;
    if (image.isPlaceholder) {
        tmpView.contentMode = UIViewContentModeCenter;
    } else {
        tmpView.contentMode = UIViewContentModeScaleAspectFit;
    }
    tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tmpView];
    
    [[AppContext currentViewController] setStatusBarHidden:YES];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^{
                         tmpView.frame = (CGRect){.origin = CGPointMake(0, originY), .size = CGSizeMake(newWidth, newHeight)};
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self p_layoutScrollViewWithFromView:fromView y:originY];
                         [tmpView removeFromSuperview];
                     }];
    
    [self p_trackerAppear];
}

#pragma mark - FQImageBrowseCellDelegate

- (void)imageBrowseCellDidTapped:(FQImageBrowseCell *)cell {
    if (self.pageControl.currentPage >= _itemArray.count) {
        return;
    }
    
    UIImageView *fromView = (UIImageView *)cell.scaleView.imageView;
    UIImageView *toView = _itemArray[self.pageControl.currentPage].thumbView;
    CGRect toFrame = [toView convertRect:toView.bounds toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
    UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fromView.frame.size.width, self.frame.size.height)];
    tmpView.hidden = YES;
    
    if (toView.image.isPlaceholder) {
        tmpView.image = toView.image;
        tmpView.contentMode = UIViewContentModeCenter;
    } else {
        UIImage *snapshotImg = [self p_snapshotImage:toView];
        tmpView.image = snapshotImg;
        tmpView.contentMode = UIViewContentModeScaleAspectFit;
    }
    tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tmpView];
    
    [[AppContext currentViewController] setStatusBarHidden:NO];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^{
                         cell.scaleView.zoomScale > cell.scaleView.minimumZoomScale
                         ? [cell.scaleView setZoomScale:cell.scaleView.minimumZoomScale]
                         : nil;
                         cell.scaleView.contentOffset = CGPointZero;
                         self.collectionView.hidden = YES;
                         tmpView.hidden = NO;
                         
                         tmpView.frame = toFrame;
                         self.contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
    [self p_trackerTransition];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQImageBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    [cell setItem:_itemArray[indexPath.row] useCache:self.useCache];
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
    CGFloat marginalValue = 100.0;
    
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
            if (_itemArray.count <= kMaxPageNumbers) {
                self.pageControl.hidden = NO;
            }
            
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
    if (_isPressed) {
        return;
    }
    
    _isPressed = YES;
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:[AppContext getStringForKey:@"picture_prompt" fileName:@"pic_sel"]
                                                                   message:[AppContext getStringForKey:@"picture_prompt_content" fileName:@"pic_sel"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_confirm" fileName:@"pic_sel"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                self->_isPressed = NO;
                                                
                                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0];
                                                FQImageBrowseCell *cell = (FQImageBrowseCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                                                if (cell && cell.scaleView) {
                                                    [cell.scaleView save];
                                                } else {
                                                    [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_save_error"
                                                                                                                     fileName:@"pic_sel"]];
                                                }
                                            }]];

    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_cancel" fileName:@"pic_sel"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                self->_isPressed = NO;
                                            }]];

    [[AppContext currentViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private

- (void)p_layoutScrollViewWithFromView:(UIView *)fromView y:(CGFloat)y {
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
    
    if (_itemArray.count > kMaxPageNumbers) {
        self.pageControl.hidden = YES;
    }
}

- (void)p_dismissWithTranslationY:(CGFloat)translationY {
    [[AppContext currentViewController] setStatusBarHidden:NO];
    
    [UIView animateWithDuration:AnimateDuration
                     animations:^(){
                         if(translationY > 0) {
                             self.collectionView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.collectionView.transform.a, self.collectionView.transform.a), 0, kScreenHeight);
                         } else {
                             self.collectionView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.collectionView.transform.a, self.collectionView.transform.a), 0, -kScreenHeight);
                         }
                         
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
    
    [self p_trackerTransition];
}

- (UIImage *)p_snapshotImage:(UIView *)view {
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)p_trackerAppear {
    beginTime = CACurrentMediaTime();
    [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Appear
                                                 cls:[self class]
                                            duration:0];
}

- (void)p_trackerTransition {
    endTime = CACurrentMediaTime();
    CFTimeInterval duration = (endTime - beginTime) * 1000;
    [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Transition
                                                 cls:[self class]
                                            duration:duration];
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
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
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
