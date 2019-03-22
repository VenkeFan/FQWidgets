//
//  WLInterestLabelSelectView.h
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelMenuView.h"

@class WLInterestLabelSelectView;

@protocol WLInterestLabelSelectViewDelegate<NSObject>

- (void)didClickInterestLabelSelectView:(WLInterestLabelSelectView *)selectView;

@end

@interface WLInterestLabelSelectView : UIScrollView

@property (nonatomic, weak) id<WLInterestLabelSelectViewDelegate> selectDelegate;

- (void)bindModels:(NSArray<WLInterestLabelMenuModel *> *)models;

@end
