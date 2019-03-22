//
//  WLTextField.h
//  welike
//
//  Created by 刘斌 on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLTextField;

@protocol WLTextFieldDelegate <NSObject>

@optional
- (BOOL)textFieldShouldBeginEditing:(WLTextField *)textField;
- (void)textFieldDidBeginEditing:(WLTextField *)textField;
- (BOOL)textFieldShouldEndEditing:(WLTextField *)textField;
- (void)textFieldDidEndEditing:(WLTextField *)textField;
- (BOOL)textField:(WLTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldClear:(WLTextField *)textField;
- (BOOL)textFieldShouldReturn:(WLTextField *)textField;

@end

@interface WLTextField : UIView

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL showLoading;
@property (nonatomic, assign) BOOL showOK;
@property (nonatomic, assign) BOOL errorState;
@property (nonatomic, assign) BOOL hideLine;
@property (nonatomic, weak) id<WLTextFieldDelegate> delegate;

@end
