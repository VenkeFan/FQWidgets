//
//  WLLoadingView.m
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLoadingView.h"

@implementation WLLoadingView

- (void)startAnimWithCenter:(CGPoint)center
{
    if ([self isAnimating] == YES) return;
    
    CGFloat width = 0;
    CGFloat height = 0;
    NSMutableArray *imageArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"loading%d", (int)(i + 1)];
        UIImage *image = [AppContext getImageForKey:imageName];
        width = image.size.width;
        height = image.size.height;
        [imageArr addObject:image];
    }
    self.frame = CGRectMake(center.x - width / 2.f, center.y - height / 2.f, width, height);
    self.animationImages = imageArr;
    self.animationRepeatCount = 0;
    self.animationDuration = 1.0;
    [self startAnimating];
}

- (void)startAnimWithPosition:(CGPoint)position
{
    if ([self isAnimating] == YES) return;
    
    CGFloat width = 0;
    CGFloat height = 0;
    NSMutableArray *imageArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++)
    {
        NSString *imageName;
        if (i + 6 <=10)
        {
            imageName = [NSString stringWithFormat:@"loading%d", (int)(i + 6)];
        }
        else
        {
             imageName = [NSString stringWithFormat:@"loading%d", (int)(i + 6 - 10)];
        }
        
        UIImage *image = [AppContext getImageForKey:imageName];
        width = image.size.width*0.7;
        height = image.size.height*0.7;
        [imageArr addObject:image];
    }
    self.frame = CGRectMake(position.x - width / 2.f, position.y, width, height);
    self.animationImages = imageArr;
    self.animationRepeatCount = 0;
    self.animationDuration = 1.0;
    [self startAnimating];
}


- (void)stopAnim
{
    [self stopAnimating];
}

@end
