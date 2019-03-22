//
//  WLTextField.m
//  welike
//
//  Created by 刘斌 on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTextField.h"
#import "WLGradientCircleLayer.h"

#define kTitleXMargin              6.f
#define kRightIconRightMargin      5.f
#define kRightLoadingSize          16.f
#define kRightOkWidth              16.f
#define kRightOkHeight             12.f

@interface WLTextField () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) WLGradientCircleLayer *gradientCircleLayer;
@property (nonatomic, strong) UIImageView *okIconView;

@end

@implementation WLTextField

- (id)init
{
    self = [super init];
    if (self)
    {
        self.textField = [[UITextField alloc] init];
        [self.textField setTintColor:kMainColor];
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.font = [UIFont systemFontOfSize:kMediumNameFontSize];
        self.textField.textColor = kNameFontColor;
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = NO;
        self.textField.delegate = self;
        [self addSubview:self.textField];
        
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
        [self addSubview:self.separateLine];
        
        self.gradientCircleLayer = [WLGradientCircleLayer layer];
        self.gradientCircleLayer.lineWidth = 2;
        self.gradientCircleLayer.circleColor = kMainColor;
        self.gradientCircleLayer.frame = CGRectMake(0, 0, kRightLoadingSize, kRightLoadingSize);
        self.gradientCircleLayer.strokeEnd = 0.9;

        self.okIconView = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"nickname_check_ok"]];
        self.okIconView.hidden = YES;
        [self addSubview:self.okIconView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kTextFieldHeight + 1)];
    if (self)
    {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.width, kTextFieldHeight)];
        [self.textField setTintColor:kMainColor];
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.font = [UIFont systemFontOfSize:kMediumNameFontSize];
        self.textField.textColor = kNameFontColor;
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = NO;
        self.textField.delegate = self;
        [self addSubview:self.textField];
        
        self.separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, kTextFieldHeight, self.width, 1.f)];
        self.separateLine.backgroundColor = kSeparateLineColor;
        [self addSubview:self.separateLine];
        
        self.gradientCircleLayer = [WLGradientCircleLayer layer];
        self.gradientCircleLayer.circleColor = kMainColor;
        self.gradientCircleLayer.lineWidth = 2;
        self.gradientCircleLayer.frame = CGRectMake(self.width - kRightIconRightMargin - self.gradientCircleLayer.frame.size.width, (self.height - self.gradientCircleLayer.frame.size.height) / 2.f, self.gradientCircleLayer.frame.size.width, self.gradientCircleLayer.frame.size.height);
        self.gradientCircleLayer.strokeEnd = 0.9;
        
        self.okIconView = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"nickname_check_ok"]];
        self.okIconView.frame = CGRectMake(self.width - kRightIconRightMargin - kRightOkWidth, (self.height - kRightOkHeight) / 2.f, kRightOkWidth, kRightOkHeight);
        self.okIconView.hidden = YES;
        [self addSubview:self.okIconView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kTextFieldHeight + 1)];
    if (self.titleLabel == nil)
    {
        self.textField.frame = CGRectMake(0, 0, self.width, kTextFieldHeight);
    }
    else
    {
        if ([_title length] > 0)
        {
            UIFont *font = [UIFont systemFontOfSize:kMediumNameFontSize];
            CGFloat width = [_title sizeWithFont:font size:CGSizeMake(self.width, kTextFieldHeight)].width;
            self.titleLabel.frame = CGRectMake(0, 0, width + kTitleXMargin * 2.f, kTextFieldHeight);
            self.textField.frame = CGRectMake(self.titleLabel.right + kTitleXMargin, 0, self.width - self.titleLabel.width - kTitleXMargin, kTextFieldHeight);
        }
        else
        {
            [self.titleLabel removeFromSuperview];
            self.titleLabel = nil;
            self.textField.frame = CGRectMake(0, 0, self.width, kTextFieldHeight);
        }
    }
    self.gradientCircleLayer.frame = CGRectMake(self.width - kRightIconRightMargin - self.gradientCircleLayer.frame.size.width, (self.height - self.gradientCircleLayer.frame.size.height) / 2.f, self.gradientCircleLayer.frame.size.width, self.gradientCircleLayer.frame.size.height);
    self.okIconView.frame = CGRectMake(self.width - kRightIconRightMargin - kRightOkWidth, (self.height - kRightOkHeight) / 2.f, kRightOkWidth, kRightOkHeight);
    self.separateLine.frame = CGRectMake(0, kTextFieldHeight, self.width, 1.f);
}

- (void)setHideLine:(BOOL)hideLine
{
    self.separateLine.hidden = hideLine;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    if ([_title length] > 0)
    {
        UIFont *font = [UIFont systemFontOfSize:kMediumNameFontSize];
        CGFloat width = [_title sizeWithFont:font size:CGSizeMake(self.width, kTextFieldHeight)].width;
        if (self.titleLabel == nil)
        {
            self.titleLabel = [[UILabel alloc] init];
        }
        else
        {
            [self.titleLabel removeFromSuperview];
        }
        self.titleLabel.frame = CGRectMake(0, 0, width + kTitleXMargin * 2.f, kTextFieldHeight);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = kNameFontColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = _title;
        self.titleLabel.font = font;
        [self addSubview:self.titleLabel];
        self.textField.frame = CGRectMake(self.titleLabel.right + kTitleXMargin, 0, self.width - self.titleLabel.width - kTitleXMargin, kTextFieldHeight);
    }
    else
    {
        if (self.titleLabel != nil)
        {
            [self.titleLabel removeFromSuperview];
            self.titleLabel = nil;
            self.textField.frame = CGRectMake(0, 0, self.width, kTextFieldHeight);
        }
    }
}

- (void)setErrorState:(BOOL)errorState
{
    _errorState = errorState;
    if (_errorState == YES)
    {
        self.separateLine.backgroundColor = kErrorNoteFontColor;
    }
    else
    {
        if ([self.textField isEditing] == YES)
        {
            self.separateLine.backgroundColor = kMainColor;
        }
        else
        {
            self.separateLine.backgroundColor = kSeparateLineColor;
        }
    }
}

- (void)setShowLoading:(BOOL)showLoading
{
    if (_showLoading != showLoading)
    {
        _showLoading = showLoading;
        if (_showLoading == YES)
        {
            self.okIconView.hidden = YES;
            [self.layer addSublayer:self.gradientCircleLayer];
            self.gradientCircleLayer.strokeEnd = 0.9;
            [self.gradientCircleLayer beginAnimating];
        }
        else
        {
            [self.gradientCircleLayer stopAnimating];
            [self.gradientCircleLayer removeFromSuperlayer];
            if (_showOK == YES)
            {
                self.okIconView.hidden = NO;
            }
            else
            {
                self.okIconView.hidden = YES;
            }
        }
    }
}

- (void)setShowOK:(BOOL)showOK
{
    _showOK = showOK;
    [self.gradientCircleLayer stopAnimating];
    [self.gradientCircleLayer removeFromSuperlayer];
    if (_showOK == YES)
    {
        self.okIconView.hidden = NO;
    }
    else
    {
        self.okIconView.hidden = YES;
    }
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.textField)
    {
        if (self.errorState == NO)
        {
            self.separateLine.backgroundColor = kMainColor;
        }
        if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)] == YES)
        {
            return [self.delegate textFieldShouldBeginEditing:self];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textField)
    {
        if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)] == YES)
        {
            [self.delegate textFieldDidBeginEditing:self];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.textField)
    {
        if (self.errorState == NO)
        {
            self.separateLine.backgroundColor = kSeparateLineColor;
        }
        if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)] == YES)
        {
            [self.delegate textFieldDidEndEditing:self];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.textField)
    {
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] == YES)
        {
            return [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:string];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.textField)
    {
        if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)] == YES)
        {
            return [self.delegate textFieldShouldClear:self];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.textField)
    {
        if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)] == YES)
        {
            return [self.delegate textFieldShouldReturn:self];
        }
    }
    return YES;
}

@end
