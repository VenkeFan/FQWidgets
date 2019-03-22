//
//  WLMaskView.m
//  welike
//
//  Created by gyb on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMaskView.h"


@implementation WLMaskView


-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
         [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMaskView)]];
    }
    return self;
}


- (void)dismissMaskView
{
    if (self.closeBlock) {
        self.closeBlock();
    }
    
    
//    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//
//        self.alpha = 0.3;
//
//    } completion:^(BOOL finished){
//        
//        if (self.closeBlock) {
//            self.closeBlock();
//        }
//    }];
}



@end
