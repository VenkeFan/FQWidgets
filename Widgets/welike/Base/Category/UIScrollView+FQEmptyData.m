//
//  UIScrollView+FQEmptyData.m
//  welike
//
//  Created by fan qi on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "UIScrollView+FQEmptyData.h"
#import <objc/runtime.h>
#import "WLDynamicLoadingView.h"

@interface FQEmptyContainerView : UIView

@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, assign) CGFloat contentTop;
@property (nonatomic, assign) WLScrollEmptyType emptyType;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) WLDynamicLoadingView *loadingView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *button;

- (void)reloadData;

@end

@implementation FQEmptyContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = kMainColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTap)];
        [self addGestureRecognizer:tap];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0)];
        _contentView.hidden = YES;
        [self addSubview:_contentView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_contentView addSubview:_imageView];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.font = kRegularFont(14);
        _descLabel.textColor = kLightFontColor;
        [_contentView addSubview:_descLabel];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = kMainColor;
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = kRegularFont(14);
        [_button addTarget:self action:@selector(selfOnTap) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_button];
    }
    return self;
}

- (void)reloadData {
    CGFloat height = 0;
    CGFloat paddingY = 50, y = 0;
    CGFloat middleX = CGRectGetMidX(_contentView.bounds);
    
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
        _descLabel.frame = CGRectMake(0, 0, 270, 0);
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
        frame.size.width += 30;
        _button.frame = frame;
        
        _button.layer.cornerRadius = CGRectGetHeight(_button.bounds) * 0.5;
        _button.center = CGPointMake(middleX, y + CGRectGetHeight(_button.bounds) * 0.5);
        y += CGRectGetHeight(_button.frame) + paddingY;
    } else {
        _button.hidden = YES;
    }
    
    height = y - paddingY;
    
    if (height > 0 && !self.isLoading) {
        _contentView.hidden = NO;
        
        CGRect frame = _contentView.frame;
        frame.size.height = height;
        _contentView.frame = frame;
        _contentView.center = CGPointMake(CGRectGetMidX(self.bounds), self.contentTop ? self.contentTop + height * 0.5 : CGRectGetMidY(self.bounds));
    } else {
        _contentView.hidden = YES;
    }
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    _contentView.hidden = loading;
    
    if (loading) {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
}

- (void)selfOnTap {
    UIScrollView *parentView = (UIScrollView *)self.superview;
    if (![parentView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    if ([parentView.emptyDelegate respondsToSelector:@selector(emptyScrollViewDidClickedBtn:)]) {
        _contentView.hidden = YES;
        [parentView.emptyDelegate emptyScrollViewDidClickedBtn:parentView];
    }
}

- (WLDynamicLoadingView *)loadingView {
    if (!_loadingView) {
        CGFloat size = 28;
        _loadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) * 0.5 - size * 0.5,
                                                                              self.contentTop ? self.contentTop + size * 0.5
                                                                              : CGRectGetHeight(self.bounds) * 0.5 - size * 0.5,
                                                                              size,
                                                                              size)];
        
//        _loadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
//        _loadingView.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5,
//                                          self.contentTop ? self.contentTop + size : CGRectGetHeight(self.bounds) * 0.5);
        [self addSubview:_loadingView];
    }
    return _loadingView;
}

@end


@interface UIScrollView ()

@property (nonatomic, weak) FQEmptyContainerView *containerView;

@end

@implementation UIScrollView (FQEmptyData)

#pragma mark - Public

- (void)reloadEmptyData {
    if (nil == self.emptyDelegate || nil == self.emptyDataSource) {
        return;
    }
    
    if ([self p_ItemsCount] > 0 && self.emptyType != WLScrollEmptyType_Empty_Topic) {
        self.containerView.hidden = YES;
        return;
    }
    
    self.containerView.hidden = NO;
    self.containerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    if ([self.emptyDataSource respondsToSelector:@selector(imageForEmptyDataSource:)]) {
        self.containerView.imageView.image = [self.emptyDataSource imageForEmptyDataSource:self];
    } else {
        id showEmptyImage = objc_getAssociatedObject(self, @selector(displayEmptyImage));
        
        if (showEmptyImage == nil || [showEmptyImage boolValue] == YES) {
            self.containerView.imageView.image = [self p_emptyImage];
        } else {
            self.containerView.imageView.image = nil;
        }
    }
    
    if ([self.emptyDataSource respondsToSelector:@selector(descriptionForEmptyDataSource:)]) {
        NSString *text = [self.emptyDataSource descriptionForEmptyDataSource:self];
        
        if (text.length == 0 && self.emptyType == WLScrollEmptyType_Empty_Network) {
            text = [self p_getDefaultDescription];
        }
        self.containerView.descLabel.text = text;
    } else {
        self.containerView.descLabel.text = [self p_getDefaultDescription];
    }
    
    if ([self.emptyDataSource respondsToSelector:@selector(buttonTitleForEmptyDataSource:)]) {
        NSString *title = [self.emptyDataSource buttonTitleForEmptyDataSource:self];
        [self.containerView.button setTitle:title forState:UIControlStateNormal];
    } else {
        [self.containerView.button setTitle:nil forState:UIControlStateNormal];
    }
    
    [self.containerView reloadData];
}

- (void)setLoading:(BOOL)loading {
    if (nil == self.emptyDelegate || nil == self.emptyDataSource) {
        return;
    }
    
    [self.containerView setLoading:loading];
    
    if (loading && [self p_ItemsCount] == 0) {
        self.containerView.hidden = NO;
    }
    
    objc_setAssociatedObject(self, @selector(isLoading), @(loading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (UIImage *)p_emptyImage {
    NSString *imageName = @"";
    
    switch (self.emptyType) {
        case WLScrollEmptyType_None:
            imageName = nil;
            break;
        case WLScrollEmptyType_Empty_Data:
            imageName = @"common_empty_data";
            break;
        case WLScrollEmptyType_Empty_Relationship:
            imageName = @"common_empty_relationship";
            break;
        case WLScrollEmptyType_Empty_Message:
            imageName = @"common_empty_message";
            break;
        case WLScrollEmptyType_Empty_Deleted:
            imageName = @"common_empty_deleted";
            break;
        case WLScrollEmptyType_Empty_Network:
            imageName = @"common_empty_network";
            break;
        case WLScrollEmptyType_Empty_Location:
            imageName = @"common_empty_location";
            break;
            
            
        case WLScrollEmptyType_Empty_Topic:
            imageName = nil;
            break;
    }
    
    if (imageName.length == 0) {
        return nil;
    }
    
    return [AppContext getImageForKey:imageName];
}

- (NSString *)p_getDefaultDescription {
    NSString *desc = @"";
    
    switch (self.emptyType) {
        case WLScrollEmptyType_Empty_Network:
            desc = [AppContext getStringForKey:@"common_error_text" fileName:@"common"];
            break;
        default:
            desc = nil;
            break;
    }
    
    return desc;
}

#pragma mark - Setter

- (void)setEmptyDelegate:(id<UIScrollViewEmptyDelegate>)emptyDelegate {
    objc_setAssociatedObject(self, @selector(emptyDelegate), emptyDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setEmptyDataSource:(id<UIScrollViewEmptyDataSource>)emptyDataSource {
    objc_setAssociatedObject(self, @selector(emptyDataSource), emptyDataSource, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setEmptyTop:(CGFloat)emptyTop {
    objc_setAssociatedObject(self, @selector(emptyTop), @(emptyTop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEmptyType:(WLScrollEmptyType)emptyType {
    objc_setAssociatedObject(self, @selector(emptyType), @(emptyType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setDisplayEmptyImage:(BOOL)displayEmptyImage {
    objc_setAssociatedObject(self, @selector(displayEmptyImage), @(displayEmptyImage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getter

- (id<UIScrollViewEmptyDelegate>)emptyDelegate {
    return objc_getAssociatedObject(self, @selector(emptyDelegate));
}

- (id<UIScrollViewEmptyDataSource>)emptyDataSource {
    return objc_getAssociatedObject(self, @selector(emptyDataSource));
}

- (BOOL)isLoading {
    return [objc_getAssociatedObject(self, @selector(isLoading)) boolValue];
}

- (CGFloat)emptyTop {
    return [objc_getAssociatedObject(self, @selector(emptyTop)) floatValue];
}

- (WLScrollEmptyType)emptyType {
    return (WLScrollEmptyType)[objc_getAssociatedObject(self, @selector(emptyType)) integerValue];
}

- (BOOL)displayEmptyImage {
    return [objc_getAssociatedObject(self, @selector(displayEmptyImage)) boolValue];
}

- (FQEmptyContainerView *)containerView {
    FQEmptyContainerView *view = (FQEmptyContainerView *)objc_getAssociatedObject(self, @selector(containerView));
    if (!view) {
        view = [[FQEmptyContainerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        view.contentTop = self.emptyTop;
        [self addSubview:view];
        objc_setAssociatedObject(self, @selector(containerView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

@end
