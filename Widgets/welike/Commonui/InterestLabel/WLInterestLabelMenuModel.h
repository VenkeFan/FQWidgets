//
//  WLInterestLabelMenuModel.h
//  welike
//
//  Created by luxing on 2018/6/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelModel.h"

@interface WLInterestLabelMenuModel : WLInterestLabelModel

@property (nonatomic, assign) CGSize groupSize;

@property (nonatomic, strong) NSArray<WLInterestLabelModel *> *labelModels;

- (void)refreshGroupSizeWithWidth:(CGFloat)width;

- (CGRect)groupFrame;

- (CGPoint)nextMenuOrigin;

- (NSUInteger)selectCount;

+ (NSArray<WLInterestLabelMenuModel *> *)modelsWithItems:(NSArray *)items;

@end
