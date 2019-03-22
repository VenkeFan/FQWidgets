//
//  WLRequestFinishAnimationVIew.m
//  welike
//
//  Created by gyb on 2018/6/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRequestFinishAnimationView.h"

@implementation WLRequestFinishAnimationView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      
        animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        animationView.image =  [AppContext getImageForKey:@"loading_finish"];
        [self addSubview:animationView];
        
         animationView.layer.transform = CATransform3DMakeScale(0, 0, 1.0);
    }
    return self;
}


-(void)startAnimation:(AnimationFinished)animationFinishedblock
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self->animationView.layer.transform = CATransform3DMakeScale(1, 1, 1.0);
        
    } completion:^(BOOL finished) {
        
        if (animationFinishedblock)
        {
            animationFinishedblock();
        }
    }];
}

-(void)stopAnimation
{
//    [animationView.layer removeAllAnimations];
//    [self removeFromSuperview];
}

-(void)initToOriginalState
{
    animationView.layer.transform = CATransform3DMakeScale(0, 0, 1.0);
}


@end
