//
//  WLInterestLabelSelectView.m
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelSelectView.h"

@interface WLInterestLabelSelectView ()<WLInterestLabelViewDelegate>

@property (nonatomic, strong) NSArray<WLInterestLabelMenuModel *> *menuModels;

@property (nonatomic, strong) NSMutableDictionary *labelMenuDic;

@end

@implementation WLInterestLabelSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setBackgroundColor:[UIColor whiteColor]];
    self.scrollEnabled = YES;
    self.labelMenuDic = [NSMutableDictionary dictionaryWithCapacity:10];
}

- (void)bindModels:(NSArray<WLInterestLabelMenuModel *> *)models
{
    self.menuModels = models;
    [self removeAllSubviews];
    CGPoint origin = CGPointMake(kInterestLabelGroupLeftPading, 0);
    CGFloat width = CGRectGetWidth(self.frame);
    for (NSInteger i = 0; i < self.menuModels.count; i++) {
        WLInterestLabelMenuModel *model = self.menuModels[i];
        [model refreshFrameWithOrigin:origin width:width];
        [model refreshGroupSizeWithWidth:width];
        origin = model.nextMenuOrigin;
        WLInterestLabelMenuView *menuView = [[WLInterestLabelMenuView alloc] initWithFrame:model.labelFrame];
        [menuView bindModel:model];
        menuView.delegate = self;
        [self addSubview:menuView];
        [self.labelMenuDic setObject:menuView forKey:model.interestId];
        self.contentSize = CGSizeMake(width, CGRectGetMaxY(menuView.frame));
        
        WLInterestLabelGroupView *groupView = [[WLInterestLabelGroupView alloc] initWithFrame:model.groupFrame];
        groupView.hidden = YES;
        groupView.delegate = self;
        [groupView bindModels:model.labelModels];
        menuView.groupView = groupView;
        [self addSubview:groupView];
        if (!model.folded) {
            groupView.hidden = NO;
            self.contentSize = CGSizeMake(width, CGRectGetMaxY(groupView.frame));
        }
    }
}

#pragma mark - WLInterestLabelViewDelegate

- (void)didClickInterestLabel:(WLInterestLabelView *)label
{
    WLInterestLabelMenuModel *model = (WLInterestLabelMenuModel*)label.labelModel;
    CGPoint origin = model.nextMenuOrigin;
    CGFloat width = CGRectGetWidth(self.frame);
    NSUInteger index = [self.menuModels indexOfObject:(WLInterestLabelMenuModel*)label.labelModel];
    for (NSInteger i = index+1; i < self.menuModels.count; i++) {
        WLInterestLabelMenuModel *model = self.menuModels[i];
        [model refreshFrameWithOrigin:origin width:width];
        origin = model.nextMenuOrigin;
    }
    WLInterestLabelMenuView *clickedMenuView = [self.labelMenuDic objectForKey:model.interestId];
    if (!model.folded) {
        clickedMenuView.groupView.hidden = NO;
        clickedMenuView.groupView.alpha = 0;
        self.contentSize = CGSizeMake(width, CGRectGetMaxY(clickedMenuView.groupView.frame));
    }
    [UIView animateWithDuration:0.5 animations:^{
        for (NSInteger i = index+1; i < self.menuModels.count; i++) {
            WLInterestLabelMenuModel *model = self.menuModels[i];
            WLInterestLabelMenuView *menuView = [self.labelMenuDic objectForKey:model.interestId];
            menuView.frame = model.labelFrame;
            self.contentSize = CGSizeMake(width, CGRectGetMaxY(menuView.frame));
            menuView.groupView.frame = model.groupFrame;
            if (!model.folded) {
                menuView.groupView.hidden = NO;
                self.contentSize = CGSizeMake(width, CGRectGetMaxY(menuView.groupView.frame));
            }
        }
        clickedMenuView.groupView.alpha = 1;
    }];
}

- (void)didClickInterestLabelImageView:(WLInterestLabelView *)label
{
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(didClickInterestLabelSelectView:)]) {
        [self.selectDelegate didClickInterestLabelSelectView:self];
    }
}

@end
