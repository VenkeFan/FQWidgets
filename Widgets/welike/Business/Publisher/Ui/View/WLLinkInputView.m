//
//  WLLinkInputView.m
//  welike
//
//  Created by gyb on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLinkInputView.h"


@implementation WLLinkInputView

-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImage *bgImage = [AppContext getImageForKey:@"publish_link_bg"];
        UIImageView  *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, bgImage.size.height)];
        bgView.image = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
        [self addSubview:bgView];
        
        UIImage *closeImage = [AppContext getImageForKey:@"publish_submit_link_close"];
        UIButton *closeBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(5, 10 + 4, 30, 30);
        [closeBtn setImage:closeImage forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        submitBtn.frame = CGRectMake(kScreenWidth - 10 - 72, 4 + 12, 72, 32);
        submitBtn.backgroundColor = kLargeBtnDisableColor;
        submitBtn.layer.cornerRadius = 16;
        submitBtn.titleLabel.font = kBoldFont(14);
        [submitBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateNormal];
        [submitBtn setTitle:[AppContext getStringForKey:@"editor_link_submit" fileName:@"publish"] forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(submitBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        submitBtn.adjustsImageWhenDisabled = NO;
        [self addSubview:submitBtn];
        submitBtn.enabled = NO;
        
      
        lineView = [[UIView alloc] initWithFrame:CGRectMake(25, bgView.height - 35 + 5, kScreenWidth - 50, 1)];
        lineView.backgroundColor = kMainColor;//kNavShadowColor;
        [self addSubview:lineView];
        
        
        linkField = [[UITextField alloc] initWithFrame:CGRectMake(25, bgView.height - 35 - 22, kScreenWidth - 50, 22)];
        linkField.keyboardType = UIKeyboardTypeURL;
        linkField.tintColor = kMainColor;
        linkField.text = @"http://";
        linkField.delegate = self;
        linkField.clearButtonMode = UITextFieldViewModeWhileEditing;
        linkField.font = kRegularFont(16);
        [self addSubview:linkField];
        
        promptLable = [[UILabel alloc] initWithFrame:CGRectMake(linkField.left, linkField.top - 25, linkField.width, 20)];
        promptLable.text = [AppContext getStringForKey:@"editor_link_note" fileName:@"publish"];
        promptLable.textColor = kMainColor;//kPlaceHolderColor;
        promptLable.numberOfLines = 1;
        promptLable.font = kRegularFont(14);
//        promptLable.backgroundColor = [UIColor blueColor];
        [self addSubview:promptLable];
    
        
    }
    return self;
}

-(void)closeBtnPressed
{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

-(void)becomeFirstResponder
{
    [linkField becomeFirstResponder];
}

-(void)submitBtnPressed
{
    if (self.submitBlock) {
        self.submitBlock(linkField.text);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) //删除的情况
    {
        NSInteger removeNum = range.length;
       // NSInteger from = range.location + range.length - 1;
       // NSLog(@"123131");
        
        if (textField.text.length == removeNum)
        {
               [self setSubmitEnable:NO];
        }
       
        
        NSMutableString *newStr = [NSMutableString stringWithString:textField.text];//[textField.text deleteCharactersInRange];
        [newStr deleteCharactersInRange:range];
        
        NSRange httpRange = [newStr rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
        NSRange httpsRange = [newStr rangeOfString:@"https://" options:NSCaseInsensitiveSearch];
        
        
        if ( httpRange.length == 0 && httpsRange.length == 0)
        {
               [self setSubmitEnable:NO];
        }
        else
        {
            if (newStr.length >= 9)
            {
                   [self setSubmitEnable:YES];

            }
            else
            {
                   [self setSubmitEnable:NO];
            }
        }
        
        
       // NSLog(@"删除===%@",newStr);
    }
    else
    {
        lineView.backgroundColor = kMainColor;
        promptLable.textColor = kMainColor;
        
        NSString *fieldString =  [NSString stringWithString:textField.text];
        NSString *finalString;
        
        if (range.length > 0)
        {
            NSLog(@"123131");
        }
        
        
        
            finalString = [NSString stringWithString:[fieldString stringByReplacingCharactersInRange:range withString:string]];
        
//        else
//        {
//           // finalString = [NSString stringWithString:[NSString stringWithFormat:@"%@%@",fieldString,string]];
//        }
        
        //delete blank,chang to lowercase
        NSString *linkStr = [NSString toLower:[finalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] ;
        
        // NSLog(@"======%@",linkStr);
        
        NSRange httpRange = [linkStr rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
        NSRange httpsRange = [linkStr rangeOfString:@"https://" options:NSCaseInsensitiveSearch];
        
        //if (([linkStr containsString:@"http://"] && linkStr.length > 7 )|| ([linkStr containsString:@"https://"] && linkStr.length > 8 ))
         if ( httpRange.length > 0 || httpsRange.length > 0)
        {
            [self setSubmitEnable:YES];
            
            
            //        //然后用正则再次验证
            //        NSArray *linkResults = [NSString matcheInString:linkStr regularExpressionWithPattern:linkRegular];
            //
            //        if (linkResults.count > 0)
            //        {
            //
            //            submitBtn.enabled = YES;
            //            submitBtn.backgroundColor = kMainColor;
            //
            //            [submitBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
            //        }
            //        else
            //        {
            //
            //            submitBtn.enabled = NO;
            //             submitBtn.backgroundColor = kLargetBtnDisableColor;
            //
            //               [submitBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
            //        }
            //    }
            //    else
            //    {
            //
            //         submitBtn.enabled = NO;
            //         submitBtn.backgroundColor = kLargetBtnDisableColor;
            //
            //           [submitBtn setTitleColor:send_text_color_disable forState:UIControlStateNormal];
            //    }
            //
        }
        else
        {
               [self setSubmitEnable:NO];
        }
        
//           NSLog(@"增加===%@",linkStr);
    }
    

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self setSubmitEnable:NO];
    
    return YES;
}


-(void)setSubmitEnable:(BOOL)enable
{
    if (enable)
    {
        submitBtn.enabled = YES;
        submitBtn.backgroundColor = kMainColor;
        [submitBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
        lineView.backgroundColor = kMainColor;
         promptLable.textColor = kMainColor;
    }
    else
    {
        submitBtn.enabled = NO;
        submitBtn.backgroundColor = kLargeBtnDisableColor;
        [submitBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateNormal];
        lineView.backgroundColor = kNavShadowColor;
        promptLable.textColor = kPlaceHolderColor;
    }
}


@end
