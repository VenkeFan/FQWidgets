//
//  WLInterestLabelMenuModel.m
//  welike
//
//  Created by luxing on 2018/6/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelMenuModel.h"

@interface WLInterestLabelMenuModel ()

@end

@implementation WLInterestLabelMenuModel

- (void)refreshGroupSizeWithWidth:(CGFloat)width
{
    CGPoint origin = CGPointMake(kInterestLabelGroupLeftPading, 0);
    for (NSInteger i = 0; i < self.labelModels.count; i++) {
        WLInterestLabelModel *model = self.labelModels[i];
        [model refreshFrameWithOrigin:origin width:width];
        origin = model.nextOrigin;
    }
    if (self.labelModels.count > 0) {
        CGSize size = CGSizeMake(width, origin.y+kInterestLabelHeight+kInterestLabelGroupTopPading);
        self.groupSize = size;
    } else {
        self.groupSize = CGSizeZero;
        self.folded = NO;
    }
}

- (CGRect)groupFrame
{
    CGFloat y = self.nextOrigin.y+kInterestLabelHeight+kInterestLabelGroupTopPading;
    return CGRectMake(0, y, self.groupSize.width, self.groupSize.height);
}

- (CGPoint)nextMenuOrigin
{
    if (self.folded || CGSizeEqualToSize(self.groupSize, CGSizeZero)) {
        return self.nextOrigin;
    } else {
        return CGPointMake(kInterestLabelGroupLeftPading, self.nextOrigin.y+kInterestLabelHeight+kInterestLabelGroupTopPading+self.groupSize.height);
    }
}

- (NSUInteger)selectCount
{
    NSUInteger count = 0;
    for (NSInteger i = 0; i < self.labelModels.count; i++) {
        WLInterestLabelModel *model = self.labelModels[i];
        if (model.isSelected) {
            count++;
        }
    }
    return count;
}

- (void)refreshModelWithItem:(NSDictionary *)item
{
    [super refreshModelWithItem:item];
    NSArray *subItems = item[kInterestLabelSubLabelsKey];
    NSMutableArray *subLabels = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger i = 0; i < subItems.count; i++) {
        NSDictionary *subItem = subItems[i];
        if ([subItem isKindOfClass:[NSDictionary class]]) {
            WLInterestLabelModel *model = [WLInterestLabelModel modelWithItem:subItem];
            if (model.interestId != nil && model.title.length > 0) {
                [subLabels addObject:model];
            }
        }
    }
    self.labelModels = subLabels;
}

+ (NSArray<WLInterestLabelMenuModel *> *)modelsWithItems:(NSArray *)items
{
    NSMutableArray *menuLabels = [NSMutableArray arrayWithCapacity:10];
    for (NSInteger i = 0; i < items.count; i++) {
        NSDictionary *item = items[i];
        if ([item isKindOfClass:[NSDictionary class]]) {
            WLInterestLabelMenuModel *model = [WLInterestLabelMenuModel modelWithItem:item];
            model.folded = YES;
            if (model.interestId != nil && model.title.length > 0) {
                [menuLabels addObject:model];
            }
        }
    }
    return menuLabels;
}

@end
