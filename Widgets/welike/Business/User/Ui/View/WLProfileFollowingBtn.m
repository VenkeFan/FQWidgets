//
//  WLProfileFollowingBtn.m
//  welike
//
//  Created by fan qi on 2019/2/15.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLProfileFollowingBtn.h"

@implementation WLProfileFollowingBtn

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setType:(WLFollowButtonType)type {
    [super setType:type];
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = kNameFontColor.CGColor;
    [self setTitle:nil forState:UIControlStateNormal];
    
    switch (type) {
        case WLFollowButtonType_Friends:
            [self setImage:[AppContext getImageForKey:@"profile_friends_2"] forState:UIControlStateNormal];
            break;
        case WLFollowButtonType_Following:
            [self setImage:[AppContext getImageForKey:@"profile_following_2"] forState:UIControlStateNormal];
            break;
        case WLFollowButtonType_None:
        case WLFollowButtonType_Followed:
            [self setImage:nil forState:UIControlStateNormal];
            break;
    }
}

@end
