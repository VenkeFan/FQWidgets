//
//  UIScrollView+FQEmptyData.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/26.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "UIScrollView+FQEmptyData.h"

@interface FQEmptyContainerView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *button;

@end

@implementation FQEmptyContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.font = kMediumFont(16);
        _descLabel.textColor = kLightFontColor;
        [self addSubview:_descLabel];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = kMainColor;
        [_button setTitleColor:kHeaderFontColor forState:UIControlStateNormal];
        _button.titleLabel.font = kMediumFont(16);
        [_button addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat height = 0;
    CGFloat x = 50, paddingY = 50, y = 0;
    CGFloat middleX = CGRectGetMidX(self.frame);
    
    if (_imageView.image) {
        _imageView.hidden = NO;
        [_imageView sizeToFit];
        _imageView.center = CGPointMake(middleX, CGRectGetMidY(_imageView.bounds));
        y += CGRectGetHeight(_imageView.frame) + paddingY;
    } else {
        _imageView.hidden = YES;
    }
    
    if (_descLabel.text.length > 0) {
        _descLabel.hidden = NO;
        _descLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) - x * 2, 0);
        [_descLabel sizeToFit];
        _descLabel.center = CGPointMake(middleX, y + CGRectGetHeight(_descLabel.bounds) * 0.5);
        y += CGRectGetHeight(_descLabel.frame) + paddingY;
    } else {
        _descLabel.hidden = YES;
    }
    
    if ([_button titleForState:UIControlStateNormal].length > 0) {
        _button.hidden = NO;
        [_button sizeToFit];
        
        CGRect frame = _button.frame;
        frame.size.width += 20;
        _button.frame = frame;
        
        _button.layer.cornerRadius = CGRectGetHeight(_button.bounds) * 0.5;
        _button.center = CGPointMake(middleX, y + CGRectGetHeight(_button.bounds) * 0.5);
        y += CGRectGetHeight(_button.frame) + paddingY;
    } else {
        _button.hidden = YES;
    }
    
    height = y - paddingY;
    
    if (height > 0) {
        self.hidden = NO;
        
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
        self.center = CGPointMake(CGRectGetMidX(self.superview.frame), CGRectGetMidY(self.superview.frame));
    } else {
        self.hidden = YES;
    }
}

- (void)btnClicked {
    UIScrollView *parentView = (UIScrollView *)self.superview;
    if (![parentView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    self.hidden = YES;
    
    if ([parentView.emptyDelegate respondsToSelector:@selector(emptyScrollViewDidClickedBtn:)]) {
        [parentView.emptyDelegate emptyScrollViewDidClickedBtn:parentView];
    }
}

@end


@interface UIScrollView ()

@property (nonatomic, weak) FQEmptyContainerView *containerView;

@end

@implementation UIScrollView (FQEmptyData)

#pragma mark - Public

- (void)reloadEmptyData {
    if ([self p_ItemsCount] > 0) {
        return;
    }
    
    if (!self.emptyDataSource) {
        return;
    }
    
    if ([self.emptyDataSource respondsToSelector:@selector(imageForEmptyDataSource:)]) {
        UIImage *emptyImage = [self.emptyDataSource imageForEmptyDataSource:self];
        self.containerView.imageView.image = emptyImage;
    }
    if ([self.emptyDataSource respondsToSelector:@selector(descriptionForEmptyDataSource:)]) {
        NSString *text = [self.emptyDataSource descriptionForEmptyDataSource:self];
        self.containerView.descLabel.text = text;
    }
    if ([self.emptyDataSource respondsToSelector:@selector(buttonTitleForEmptyDataSource:)]) {
        NSString *title = [self.emptyDataSource buttonTitleForEmptyDataSource:self];
        [self.containerView.button setTitle:title forState:UIControlStateNormal];
    }
    
    [self.containerView setNeedsLayout];
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
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        
        if ([collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [collectionView.dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if ([collectionView.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger i = 0; i < sections; i++) {
                count += [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:i];
            }
        }
    }
    
    return count;
}

#pragma mark - Setter

- (void)setEmptyDelegate:(id<UIScrollViewEmptyDelegate>)emptyDelegate {
    objc_setAssociatedObject(self, @selector(emptyDelegate), emptyDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setEmptyDataSource:(id<UIScrollViewEmptyDataSource>)emptyDataSource {
    objc_setAssociatedObject(self, @selector(emptyDataSource), emptyDataSource, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - Getter

- (id<UIScrollViewEmptyDelegate>)emptyDelegate {
    return objc_getAssociatedObject(self, @selector(emptyDelegate));
}

- (id<UIScrollViewEmptyDataSource>)emptyDataSource {
    return objc_getAssociatedObject(self, @selector(emptyDataSource));
}

- (FQEmptyContainerView *)containerView {
    FQEmptyContainerView *view = (FQEmptyContainerView *)objc_getAssociatedObject(self, @selector(containerView));
    if (!view) {
        view = [[FQEmptyContainerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0)];
        view.hidden = YES;
        [self addSubview:view];
        objc_setAssociatedObject(self, @selector(containerView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

@end
