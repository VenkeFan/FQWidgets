//
//  WLMagicContentView.m
//  welike
//
//  Created by fan qi on 2018/11/26.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicContentView.h"
#import "WLMagicEffectView.h"
#import "WLSegmentedControl.h"

#define kMagicContentViewHeight         (240 + kSafeAreaBottomY)
#define kMagicSegmentedHeight           40

@interface WLMagicContentView () <WLSegmentedControlDelegate, WLMagicEffectViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WLMagicEffectView *filterView;
@property (nonatomic, strong) WLMagicEffectView *pasterView;
@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;

@end

@implementation WLMagicContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)]) {
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        
        [self setUpSubViews];
        [self addGestures];
    }
    return self;
}

- (void)setUpSubViews {
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, CGRectGetWidth(self.bounds), kMagicContentViewHeight)];
    _contentView.backgroundColor = kUIColorFromRGBA(0x000000, 0.5);
    [self addSubview:_contentView];
    
    _scrollView = ({
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:_contentView.bounds];
        sv.delegate = self;
        sv.showsHorizontalScrollIndicator = NO;
        sv.pagingEnabled = YES;
        
        NSInteger numbersInRow = 4;
        CGFloat spacing = 12.0;
        CGFloat txtHeight = 16.0;
        CGFloat width = (kScreenWidth - (numbersInRow + 1) * spacing) / numbersInRow;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = spacing;
        layout.minimumInteritemSpacing = spacing;
        layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, kMagicSegmentedHeight + spacing, spacing);
        layout.itemSize = CGSizeMake(width, width + txtHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _filterView = [[WLMagicEffectView alloc] initWithFrame:sv.bounds];
        _filterView.effectType = WLMagicEffectViewType_Filter;
        _filterView.collectionLayout = layout;
        _filterView.delegate = self;
        [sv addSubview:_filterView];
        
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = spacing;
        layout.minimumInteritemSpacing = spacing;
        layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, kMagicSegmentedHeight + spacing, spacing);
        layout.itemSize = CGSizeMake(width, width);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _pasterView = [[WLMagicEffectView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, CGRectGetWidth(sv.bounds), CGRectGetHeight(sv.bounds))];
        _pasterView.effectType = WLMagicEffectViewType_Paster;
        _pasterView.collectionLayout = layout;
        _pasterView.delegate = self;
        [sv addSubview:_pasterView];
        
        sv;
    });
    [_contentView addSubview:_scrollView];
    
    _segmentedCtr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_contentView.bounds) - kMagicSegmentedHeight - kSafeAreaBottomY, CGRectGetWidth(self.bounds), kMagicSegmentedHeight + kSafeAreaBottomY)];
    _segmentedCtr.backgroundColor = kUIColorFromRGBA(0x000000, 0.5);
    _segmentedCtr.hSeparateLineColor = [UIColor clearColor];
    _segmentedCtr.tintColor = [UIColor whiteColor];
    _segmentedCtr.onTintColor = kMainColor;
    _segmentedCtr.delegate = self;
    _segmentedCtr.items = @[[AppContext getStringForKey:@"camera_filter" fileName:@"common"],
                            [AppContext getStringForKey:@"camera_picture" fileName:@"common"]];
    _segmentedCtr.currentIndex = 0;
    [_contentView addSubview:_segmentedCtr];
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * _segmentedCtr.items.count, 0);
}

- (void)addGestures {
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnSwiped:)];
    leftSwipe.cancelsTouchesInView = YES;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnSwiped:)];
    rightSwipe.cancelsTouchesInView = YES;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipe];
}

#pragma mark - Public

- (void)fetchFilterArray {
    [self.filterView display];
}

- (void)display {
    [self displayWithIndex:0];
}

- (void)displayWithIndex:(NSInteger)index {
    self.segmentedCtr.currentIndex = index;
    
    if (index == 0) {
        [self.filterView display];
    } else {
        [self.pasterView display];
    }
    
    self.hidden = NO;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.contentView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.contentView.bounds));
                     }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.contentView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
}

- (WLMagicBasicModel *)previousFilter {
    return [self.filterView previousFilter];
}

- (WLMagicBasicModel *)nextFilter {
    return [self.filterView nextFilter];
}

#pragma mark - WLMagicEffectViewDelegate

- (void)magicEffectView:(WLMagicEffectView *)effectView selectedModel:(WLMagicBasicModel *)selectedModel {
    if ([self.delegate respondsToSelector:@selector(magicContentViewDidSelectedModel:)]) {
        [self.delegate magicContentViewDidSelectedModel:selectedModel];
    }
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control
        didSelectedIndex:(NSInteger)index
                preIndex:(NSInteger)preIndex {
    [UIView animateWithDuration:index == preIndex ? 0.0 : 0.25
                     animations:^{
                         self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds) * index, 0);
                     }
                     completion:^(BOOL finished) {
                         if (index == 0) {
                             [self.filterView display];
                         } else {
                             [self.pasterView display];
                         }
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.segmentedCtr.currentIndex = index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentedCtr setLineOffsetX:scrollView.contentOffset.x];
}

#pragma mark - Event

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
       [self dismiss];
    }
}

- (void)selfOnSwiped:(UISwipeGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(magicContentViewDidSwiped:)]) {
        [self.delegate magicContentViewDidSwiped:gesture];
    }
}

@end
