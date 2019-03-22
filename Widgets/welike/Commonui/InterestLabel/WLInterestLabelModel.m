//
//  WLInterestLabelModel.m
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelModel.h"

@implementation WLInterestLabelModel

- (CGFloat)interestLabelWidth
{
    CGSize contentSize = [self.title boundingRectWithSize:CGSizeMake(MAXFLOAT, kInterestLabelHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kInterestLabelTitleFontSize]} context:nil].size;
    return contentSize.width+2*kInterestLabelLeftPadding;
}

- (void)refreshFrameWithOrigin:(CGPoint)origin width:(CGFloat)width
{
    CGFloat maxWidth = width - 2*kInterestLabelGroupLeftPading;
    CGFloat w = [self interestLabelWidth];
    w = MIN(w, maxWidth);
    CGRect labelRect = CGRectZero;
    if (origin.x+w <= kInterestLabelGroupLeftPading + maxWidth) {
        labelRect = CGRectMake(origin.x, origin.y, w, kInterestLabelHeight);
    } else {
        labelRect = CGRectMake(kInterestLabelGroupLeftPading, origin.y+kInterestLabelHeight+kInterestLabelGroupTopPading, w, kInterestLabelHeight);
    }
    self.labelFrame = labelRect;
    CGPoint next = CGPointMake(CGRectGetMaxX(labelRect)+kInterestLabelViewPading, CGRectGetMinY(labelRect));
    self.nextOrigin = next;
}

- (void)refreshModelWithItem:(NSDictionary *)item
{
    self.interestId = item[kInterestLabelIdKey];
    self.title = item[kInterestLabelTitleKey];
    self.imageUrl = [item[kInterestLabelImageUrlKey] convertToHttps];
    self.isSelected = [item[kInterestLabelSelectedKey] boolValue];
}

+ (instancetype)modelWithItem:(NSDictionary *)item
{
    id model = [[[self class] alloc] init];
    [model refreshModelWithItem:item];
    return model;
}

@end
