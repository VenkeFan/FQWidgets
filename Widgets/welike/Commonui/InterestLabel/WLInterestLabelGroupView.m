//
//  WLInterestLabelGroupView.m
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelGroupView.h"

@interface WLInterestLabelGroupView ()

@property (nonatomic, strong) NSArray<WLInterestLabelModel *> *labelModels;

@end

@implementation WLInterestLabelGroupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)bindModels:(NSArray<WLInterestLabelModel *> *)models
{
    self.labelModels = models;
    [self removeAllSubviews];
    for (NSInteger i = 0; i < self.labelModels.count; i++) {
        WLInterestLabelModel *model = self.labelModels[i];
        WLInterestLabelView *labelView = [[WLInterestLabelView alloc] initWithFrame:model.labelFrame];
        [labelView bindModel:model];
        labelView.delegate = self.delegate;
        [self addSubview:labelView];
    }
}

@end
