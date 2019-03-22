//
//  WLPublishCheckBox.h
//  welike
//
//  Created by gyb on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLDraft.h"


@interface WLPublishCheckBox : UIView
{
    UIButton *checkBoxBtn;
    UILabel *promptLabel;

}


@property (readonly,assign,nonatomic) BOOL isCheck;

//@property (nonatomic,copy) void(^checkSelect)(BOOL isCheck);


- (id)initWithFrame:(CGRect)frame type:(WELIKE_DRAFT_TYPE)type;

-(void)select;

@end
