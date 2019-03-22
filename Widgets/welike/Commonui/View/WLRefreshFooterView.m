//
//  WLRefreshFooterView.m
//  welike
//
//  Created by fan qi on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRefreshFooterView.h"
#import "WLDynamicLoadingView.h"

#define defaultFooterHeight         30

@interface WLRefreshFooterView ()

@property (nonatomic, weak) UIScrollView *parentView;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL refreshAction;

@property (nonatomic, strong) UIButton *loadBtn;
@property (nonatomic, strong) WLDynamicLoadingView *loadingView;

@end

@implementation WLRefreshFooterView {
    CGFloat _originalInsetsBottom;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self removeObservers];
    
    if (![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    _parentView = (UIScrollView *)newSuperview;
    self.frame = CGRectMake(0, _parentView.contentSize.height, CGRectGetWidth(_parentView.bounds), defaultFooterHeight);
//    _originalInsetsBottom = _parentView.contentInset.bottom;
    
    [self addObservers];
}

- (void)addObservers {
    [_parentView addObserver:self
                  forKeyPath:@"contentSize"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
    
    [_parentView addObserver:self
                  forKeyPath:@"contentOffset"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
    
    [_parentView addObserver:self
                  forKeyPath:@"contentInset"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
}

- (void)removeObservers {
    [self.superview removeObserver:self forKeyPath:@"contentSize"];
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    [self.superview removeObserver:self forKeyPath:@"contentInset"];
}

- (void)dealloc {
    [self removeObservers];
}

#pragma mark - Public

- (void)addTarget:(id)target refreshAction:(SEL)refreshAction {
    _target = target;
    _refreshAction = refreshAction;
}

- (void)setStatus:(WLRefreshFooterStatus)status {
    if (_status == status) {
        return;
    }
    
    _status = status;
    
    [self.loadBtn setImage:nil forState:UIControlStateNormal];
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
    
    switch (status) {
        case WLRefreshFooterStatus_Idle:
            [self.loadBtn setTitle:[AppContext getStringForKey:@"loading" fileName:@"common"] forState:UIControlStateNormal];
            break;
        case WLRefreshFooterStatus_Pulling:
            
            break;
            
        case WLRefreshFooterStatus_Refreshing: {
            UIImage *loadingImg = [AppContext getImageForKey:@"common_loading"];
            loadingImg = [loadingImg resizeWithSize:CGSizeMake(self.loadBtn.titleLabel.font.pointSize, self.loadBtn.titleLabel.font.pointSize)];
            loadingImg = [loadingImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.loadBtn setImage:loadingImg forState:UIControlStateNormal];
            
            [self.loadBtn.imageView addSubview:self.loadingView];
            [self.loadingView startAnimating];
            
            [self p_executeAction];
        }
            break;
    }
}

- (void)setResult:(WLRefreshFooterResult)result {
    _result = result;
    
    switch (result) {
        case WLRefreshFooterResult_None:
            [self.loadBtn setTitle:[AppContext getStringForKey:@"loading" fileName:@"common"] forState:UIControlStateNormal];
            break;
        case WLRefreshFooterResult_NoMore:
            [self.loadBtn setTitle:[AppContext getStringForKey:@"no_more" fileName:@"common"] forState:UIControlStateNormal];
            break;
        case WLRefreshFooterResult_HasMore:
            [self.loadBtn setTitle:[AppContext getStringForKey:@"loading" fileName:@"common"] forState:UIControlStateNormal];
            break;
        case WLRefreshFooterResult_Error:
            [self.loadBtn setTitle:[AppContext getStringForKey:@"load_error" fileName:@"common"] forState:UIControlStateNormal];
            break;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        if (_parentView.contentSize.height > 0) {
            CGRect frame = self.frame;
            frame.origin.y = _parentView.contentSize.height;
            self.frame = frame;
        } else {
            CGRect frame = self.frame;
            frame.origin.y = _parentView.frame.size.height;
            self.frame = frame;
        }
        _parentView.contentInset = UIEdgeInsetsMake(_parentView.contentInset.top, 0, _originalInsetsBottom + CGRectGetHeight(self.frame), 0);
        
    } else if ([keyPath isEqualToString:@"contentInset"]) {
        if (change[NSKeyValueChangeNewKey]) {
            UIEdgeInsets newInsets = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
            
            if (newInsets.bottom != 0 && newInsets.bottom != CGRectGetHeight(self.frame)) {
                _originalInsetsBottom = newInsets.bottom - CGRectGetHeight(self.frame);
            }
        }
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Event

- (void)loadBtnClicked {
    if (self.status == WLRefreshFooterStatus_Refreshing || self.status == WLRefreshFooterStatus_Pulling) {
        return;
    }
    
    if (self.result == WLRefreshFooterResult_Error) {
        [self setStatus:WLRefreshFooterStatus_Refreshing];
    }
}

#pragma mark - Private

- (void)p_executeAction {
    [self setResult:WLRefreshFooterResult_None];
    
    if (_target && [_target respondsToSelector:_refreshAction]) {
        IMP imp = [_target methodForSelector:_refreshAction];
        void (*fun)(id, SEL) = (void *)imp;
        fun(_target, _refreshAction);
    }
}

#pragma mark - Getter

- (UIButton *)loadBtn {
    if (!_loadBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tintColor = [UIColor clearColor];
        btn.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        [btn setTitle:[AppContext getStringForKey:@"loading" fileName:@"common"] forState:UIControlStateNormal];
        [btn setTitleColor:kLightLightFontColor forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        btn.titleLabel.font = kRegularFont(kLinkFontSize);
        [btn addTarget:self action:@selector(loadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _loadBtn = btn;
    }
    return _loadBtn;
}

- (WLDynamicLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.loadBtn.titleLabel.font.pointSize, self.loadBtn.titleLabel.font.pointSize)];
        _loadingView.lineWidth = 2.0;
    }
    return _loadingView;
}

@end
