//
//  WLVoteSingleView.m
//  welike
//
//  Created by gyb on 2018/10/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVoteSingleView.h"
#import "WLAssetModel.h"
#import "WLImageHelper.h"
#import "YYTextView.h"
//#import "IQKeyboardManager.h"

@interface WLVoteSingleView () <YYTextViewDelegate>

@end

@implementation WLVoteSingleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
//        self.backgroundColor = [UIColor redColor];
        lineFrameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 15 - 38, 32)];
        lineFrameView.layer.cornerRadius = 3;
        lineFrameView.layer.borderWidth = 1;
        lineFrameView.layer.borderColor = kNavShadowColor.CGColor;
        [self addSubview:lineFrameView];
        
        optionTextView = [[YYTextView alloc] initWithFrame:CGRectMake(5, 0, lineFrameView.width - 5 - 34, 32)];
        optionTextView.font = kRegularFont(14);
        optionTextView.placeholderText = _placeHolderStr;
        optionTextView.textColor = kPublishEditColor;
//        optionTextView.
//        optionTextView.backgroundColor = [UIColor orangeColor];
        optionTextView.delegate = self;
        [lineFrameView addSubview:optionTextView];
        
//        [[IQKeyboardManager sharedManager] setEnable:YES];
//        [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:80];
//        [[IQKeyboardManager sharedManager] registerTextFieldViewClass:[YYTextView class] didBeginEditingNotificationName:YYTextViewTextDidBeginEditingNotification didEndEditingNotificationName:YYTextViewTextDidEndEditingNotification];
        
        
        
        
        picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        picBtn.frame = CGRectMake(lineFrameView.width - 34, 1, 34, 30);
        picBtn.backgroundColor = kBorderLineColor;
        [picBtn setImage:[AppContext getImageForKey:@"publish_camare"] forState:UIControlStateNormal];
        [picBtn addTarget:self action:@selector(picBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        picBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [lineFrameView addSubview:picBtn];
        
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(lineFrameView.right, 1, 38, 30);
//        closeBtn.backgroundColor = [UIColor greenColor];
        [closeBtn setImage:[AppContext getImageForKey:@"publish_gridPic_delete"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
    }
    return self;
}


-(void)setPlaceHolderStr:(NSString *)placeHolderStr
{
    _placeHolderStr = placeHolderStr;
    optionTextView.placeholderText = _placeHolderStr;
}

-(void)setDeleteBtnEnable:(BOOL)deleteBtnEnable
{
    _deleteBtnEnable = deleteBtnEnable;
    
    closeBtn.enabled = _deleteBtnEnable;
}

-(void)setAssetModel:(WLAssetModel *)assetModel
{
    _assetModel = assetModel;
    
    PHAsset *asset = [assetModel asset];
    
    [self setType:1];
    
    [WLImageHelper imageFromAsset:asset size:CGSizeMake(picBtn.width*3, picBtn.height*3) result:^(UIImage *thumbImage) {
        [self->picBtn setImage:thumbImage forState:UIControlStateNormal];
    }];
}

-(void)setType:(NSInteger)type
{
    _type = type;
    
    if (_type == 0) //文字模式
    {
        lineFrameView.frame = CGRectMake(0, 0, kScreenWidth - 15 - 38, 32);
        optionTextView.frame = CGRectMake(5, 1, lineFrameView.width - 5 - 34, 32);
        picBtn.frame = CGRectMake(lineFrameView.width - 34, 1, 34, 30);
        closeBtn.frame = CGRectMake(lineFrameView.right, 1, 38, 30);
    }
    else //图片模式
    {
        lineFrameView.frame = CGRectMake(0, 0, (kScreenWidth - 15*2 - 8)/2.0, ((kScreenWidth - 8 - 30)/2.0)*0.75 + 48);
        picBtn.frame = CGRectMake(0, 0, lineFrameView.width, lineFrameView.height - 48);
        optionTextView.frame = CGRectMake(8, picBtn.bottom + 5, lineFrameView.width - 10, 38);
        closeBtn.frame = CGRectMake(lineFrameView.width - 38, 1, 38, 30);
    }
}


-(void)picBtnPressed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(addImage:)])
    {
        [_delegate addImage:self];
    }
}

-(void)closeBtnPressed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(deleteOption:)])
    {
        [_delegate deleteOption:self];
    }
}

-(NSString *)inputStr
{
    NSString *strWithoutBlankLeftAndRight = [optionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return strWithoutBlankLeftAndRight;
}

- (void)textViewDidBeginEditing:(YYTextView *)textView
{
    lineFrameView.layer.borderColor = kMainColor.CGColor;
    if ([_delegate respondsToSelector:@selector(optionTextViewIsBeginEdit:)])
    {
        [_delegate optionTextViewIsBeginEdit:self];
    }
}

- (void)textViewDidEndEditing:(YYTextView *)textView
{
    lineFrameView.layer.borderColor = kNavShadowColor.CGColor;
    if ([_delegate respondsToSelector:@selector(optionTextViewIsEndEdit:)])
    {
        [_delegate optionTextViewIsEndEdit:self];
    }
}


- (void)textViewDidChange:(YYTextView *)textView
{
   //  NSLog(@"text======%@",textView.text);
    
    //when change > screenheight,change position of thunbView
    if ([_delegate respondsToSelector:@selector(inputNum:)])
    {
        [_delegate inputNum:self];
    }
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *searchString;
    
    //return 无效化
    if ([text isEqualToString:@"\n"]){
        return NO;
    }
    
    
    if (range.length > 0)
    {
        searchString = [NSString stringWithString:[textView.text stringByReplacingCharactersInRange:range withString:text]];
    }
    else
    {
        searchString = [NSString stringWithFormat:@"%@%@",textView.text,text];
    }
    
    //判断超过32长度
    if (searchString.length > 32)
    {
        return NO;
    }
    
    return YES;
}

@end
