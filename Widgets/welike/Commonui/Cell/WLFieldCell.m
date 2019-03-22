//
//  WLFieldCell.m
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFieldCell.h"
#import "UIView+LuuBase.h"
#import "LuuUtils.h"
#import "WLUIResourceDefine.h"

@interface WLFieldCell () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *contentPlaceholder;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) UIKeyboardType editingKeyboardType;
@property (nonatomic, assign) BOOL editingSecureTextEntry;

@property (nonatomic, strong) UITextField *contentField;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLFieldCell

- (void)setContentPlaceholder:(NSString *)contentPlaceholder
{
    _contentPlaceholder = [contentPlaceholder copy];
    if ([_contentPlaceholder length] > 0)
    {
        self.contentField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_contentPlaceholder attributes:@{NSForegroundColorAttributeName:kLightLightFontColor, NSFontAttributeName:[UIFont systemFontOfSize:kBodyFontSize]}];
        [self.contentField setPlaceholder:_contentPlaceholder];
    }
}

- (void)setContent:(NSString *)content
{
    _content = [content copy];
    if ([_content length] > 0)
    {
        if (self.editingSecureTextEntry == YES)
        {
            NSMutableString *secureText = [[NSMutableString alloc] initWithCapacity:[_content length]];
            for (NSInteger i = 0; i < [_content length]; i++)
            {
                [secureText appendString:@"*"];
            }
            [self.contentField setText:secureText];
        }
        else
        {
            [self.contentField setText:_content];
        }
    }
    else
    {
         [self.contentField setText:nil];
    }
}

- (void)setEditingKeyboardType:(UIKeyboardType)editingKeyboardType
{
    _editingKeyboardType = editingKeyboardType;
    self.contentField.keyboardType = _editingKeyboardType;
}

- (void)setEditingSecureTextEntry:(BOOL)editingSecureTextEntry
{
    _editingSecureTextEntry = editingSecureTextEntry;
    self.contentField.secureTextEntry = _editingSecureTextEntry;
}

- (void)endEditingStatus
{
    [self.contentField resignFirstResponder];
}

- (BOOL)isTextFieldFocused
{
    return [self.contentField isFirstResponder];
}

- (void)setDataSourceItem:(WLFieldDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    CGFloat cellHeight = [item calculateCellHeight];
    CGFloat cellWidth = [LuuUtils mainScreenBounds].width;
    
    self.content = item.content;
    self.contentPlaceholder = item.placeholder;
    self.editingKeyboardType = item.editingKeyboardType;
    self.editingSecureTextEntry = item.secureTextEntry;
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
    }
    self.separateLine.frame = CGRectMake(item.leftMargin, cellHeight - 0.5f, cellWidth - item.leftMargin - item.rightMargin, 0.5f);
    self.separateLine.backgroundColor = kSeparateLineColor;
    [self.contentView addSubview:self.separateLine];
    
    if (self.contentField == nil)
    {
        self.contentField = [[UITextField alloc] init];
    }
    self.contentField.frame = CGRectMake(item.leftMargin, 0, cellWidth - item.leftMargin - item.rightMargin, cellHeight);
    [self.contentField setTintColor:kMainColor];
    self.contentField.backgroundColor = [UIColor clearColor];
    self.contentField.borderStyle = UITextBorderStyleNone;
    self.contentField.font = [UIFont systemFontOfSize:kBodyFontSize];
    self.contentField.textColor = kNameFontColor;
    self.contentField.returnKeyType = UIReturnKeyDone;
    self.contentField.keyboardType = self.editingKeyboardType;
    self.contentField.secureTextEntry = self.editingSecureTextEntry;
    self.contentField.textAlignment = NSTextAlignmentLeft;
    self.contentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.contentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.contentField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.contentField.autocorrectionType = NO;
    self.contentField.delegate = self;
    self.contentField.placeholder = item.placeholder;
    self.contentField.text = item.content;
    [self.contentView addSubview:self.contentField];
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(cellIndex:textFieldText:shouldChangeCharactersInRange:replacementString:)])
    {
        return [self.delegate cellIndex:self.indexPath textFieldText:textField.text shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.contentField == textField)
    {
        if ([self.delegate respondsToSelector:@selector(cellIndexDidBeginEditing:)])
        {
            [self.delegate cellIndexDidBeginEditing:self.indexPath];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.contentField == textField)
    {
        NSString *contentText = [self.contentField.text copy];
        self.content = contentText;
        if ([self.delegate respondsToSelector:@selector(cellIndex:didEndEditingWithContent:)])
        {
            [self.delegate cellIndex:self.indexPath didEndEditingWithContent:self.content];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.contentField == textField)
    {
        if ([self.delegate respondsToSelector:@selector(cellIndexShouldClear:)])
        {
            return [self.delegate cellIndexShouldClear:self.indexPath];
        }
    }
    return YES;
}

@end
