//
//  WLTopicThumbView.h
//  welike
//
//  Created by gyb on 2018/8/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLTopicThumbView : UIView
{
    UIImageView *thumbView1;
    UIImageView *thumbView2;
    UIImageView *thumbView3;
    UIImageView *thumbView4;
    
    NSArray *thumbArray;
    
    
}


@property (strong, nonatomic) NSArray *pics;

@end
