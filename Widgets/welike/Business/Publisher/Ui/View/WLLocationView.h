//
//  WLLocationView.h
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WLLocationViewDelegate <NSObject>

-(void)locationBtnPressed;


-(void)locationDeleteBtnPressed;

@end

@interface WLLocationView : UIView
{
    UIButton *locationBtn;
    UILabel *locationLabel;
    UIImageView *locationImageView;
    UIButton *deleteBtn;
}

@property (weak,nonatomic) id delegate;

-(void)changeLocvationName:(NSString *)locationStr;

@end
