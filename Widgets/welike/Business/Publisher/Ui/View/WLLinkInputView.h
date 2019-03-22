//
//  WLLinkInputView.h
//  welike
//
//  Created by gyb on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WLLinkInputView : UIView<UITextFieldDelegate>
{
    UITextField *linkField;
    
    UIButton *submitBtn;
    
    UIView *lineView;
    
    UILabel *promptLable;
}


@property (nonatomic,copy) void(^closeBlock)(void);
@property (nonatomic,copy) void(^submitBlock)(NSString *linkStr);


-(void)becomeFirstResponder;

-(void)closeBtnPressed;

@end
