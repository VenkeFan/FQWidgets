//
//  WLInterestLabelGroupView.h
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestLabelView.h"
#import "WLInterestLabelMenuModel.h"

@interface WLInterestLabelGroupView : UIView

@property (nonatomic, weak) id<WLInterestLabelViewDelegate> delegate;

- (void)bindModels:(NSArray<WLInterestLabelModel *> *)models;

@end
