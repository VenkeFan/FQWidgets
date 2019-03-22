//
//  WLLoadingDlg.m
//  welike
//
//  Created by 刘斌 on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLoadingDlg.h"
#import "WLDynamicLoadingView.h"

#define kLoadingSize      54.0f

@interface WLLoadingDlg ()

@property (nonatomic, strong) UIView *subCover;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) WLDynamicLoadingView *loadingView;

@end

@implementation WLLoadingDlg

- (void)show:(UIView *)parent
{
    if (self.isShow == NO)
    {
        self.isShow = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, [LuuUtils mainScreenBounds].width, [LuuUtils mainScreenBounds].height);
        
        self.subCover = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - kLoadingSize / 2.f, self.center.y - kLoadingSize / 2.f, kLoadingSize, kLoadingSize)];
        self.subCover.layer.cornerRadius = 5.0;
        self.subCover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        
        [self addSubview:self.subCover];
        
        _loadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _loadingView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_loadingView];
        [_loadingView startAnimating];
        
        [parent addSubview:self];
    }
}

- (void)hide
{
    self.isShow = NO;
   
    [_loadingView stopAnimating];
    [self removeAllSubviews];
    
    self.subCover = nil;
    
    [self removeFromSuperview];
}

@end
