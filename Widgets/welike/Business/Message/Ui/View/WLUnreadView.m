//
//  WLUnreadView.m
//  welike
//
//  Created by luxing on 2018/6/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnreadView.h"

@implementation WLUnreadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _badgeView = [[WLBadgeView alloc] initWithParentView:self size:frame.size.width fontSize:kSmallBadgeNumFontSize];
        _badgeView.adjustX = -frame.size.width/2.0;
        _badgeView.adjustY = frame.size.width/2.0;
        _badgeView.hidden = YES;
    }
    return self;
}

- (void)setUnreadCount:(NSInteger)unread
{
    _unreadCount = unread;
    if (unread > 0) {
        self.badgeView.badgeNumber = unread;
        self.badgeView.hidden = NO;
    } else {
        self.badgeView.hidden = YES;
    }
}

@end
