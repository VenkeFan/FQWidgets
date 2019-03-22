//
//  WLRequestFinishAnimationVIew.h
//  welike
//
//  Created by gyb on 2018/6/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AnimationFinished)(void);

@interface WLRequestFinishAnimationView : UIView
{
    UIImageView *animationView;
}


-(void)startAnimation:(AnimationFinished)animationFinishedblock;

-(void)stopAnimation;

-(void)initToOriginalState;

@end
