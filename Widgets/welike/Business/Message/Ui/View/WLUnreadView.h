//
//  WLUnreadView.h
//  welike
//
//  Created by luxing on 2018/6/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLBadgeView.h"

#define kChatBoxCellBadgeRightMargin                 36.f
#define kChatBoxCellBadgeSize                        20.f

@interface WLUnreadView : UIView

@property (nonatomic,strong) WLBadgeView *badgeView;
@property (nonatomic, assign) NSInteger unreadCount;

@end
