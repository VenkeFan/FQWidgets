//
//  WLTopicSearchSectionView.h
//  welike
//
//  Created by gyb on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLTopicSearchSectionView : UIView
{
    UIView *lightView;
    UILabel *promptLabel;
    UILabel *desLabel;
    UIView *lineView;
}


@property (copy,nonatomic) NSString *titleStr;
@property (copy,nonatomic) NSString *desStr;
//@property (copy,nonatomic) NSMutableAttributedString *attributedString;


-(void)hideLine;

@end
