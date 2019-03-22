//
//  WLLoadingView.h
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLLoadingView : UIImageView

- (void)startAnimWithCenter:(CGPoint)center;
- (void)startAnimWithPosition:(CGPoint)position;
- (void)stopAnim;

@end
