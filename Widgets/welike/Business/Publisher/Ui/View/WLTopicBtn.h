//
//  WLTopicBtn.h
//  welike
//
//  Created by gyb on 2018/11/7.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WLTopicBtn : UIButton
{
    UILabel *titleLable;
    
    UIImageView *triangleView;
}


-(void)changeToEnable;
-(void)changeToDisable;

@end
