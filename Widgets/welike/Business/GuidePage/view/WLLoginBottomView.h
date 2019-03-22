//
//  WLLoginBottomView.h
//  welike
//
//  Created by gyb on 2018/8/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLLoginBottomViewDelegate<NSObject>

-(void)clickGoogle;
-(void)clickFacebook;

@end


@interface WLLoginBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame withImageArray:(NSArray *)nameArray withTitleArray:(NSArray *)titleArray;



@property (weak,nonatomic) id delagate;


@end
