//
//  WLBadgeInfoPopView.h
//  welike
//
//  Created by fan qi on 2019/2/21.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLBadgeModel;

NS_ASSUME_NONNULL_BEGIN

@interface WLBadgeInfoPopView : UIView

@property (nonatomic, strong) WLBadgeModel *itemModel;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
