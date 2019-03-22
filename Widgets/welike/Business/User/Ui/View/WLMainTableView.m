//
//  WLMainTableView.m
//  welike
//
//  Created by fan qi on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMainTableView.h"

@implementation WLMainTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.backgroundColor = [UIColor whiteColor];
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.showsVerticalScrollIndicator = NO;

//        if (@available(iOS 11.0, *)){
//            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
