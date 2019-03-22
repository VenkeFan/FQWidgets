//
//  WLInputTextView.m
//  welike
//
//  Created by luxing on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInputTextView.h"

@implementation WLInputTextView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont systemFontOfSize:kTextViewDefaultFontSize];
        self.backgroundColor = kTextViewDefaultFillColor;
        self.textColor = kTextViewDefaultTextColor;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.cornerRadius = kTextViewCornerRadius;
        self.layer.borderWidth = kTextViewBorderWidth;
        self.contentMode = UIViewContentModeRedraw;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.returnKeyType = UIReturnKeySend;
        self.enablesReturnKeyAutomatically = YES;
        
        _placeHolder = nil;
        _placeHolderTextColor = kTextViewDefaultPlaceHolderColor;
        
        [self addTextViewNotificationObservers];
    }
    return self;
}

- (void)dealloc
{
    [self removeTextViewNotificationObservers];
}

- (void)deleteBackward
{
    if (IsTextContainFace(self.text)) { // 如果text中有表情
        if ([self.userDelegate respondsToSelector:@selector(textViewDeleteBackward:)]) {
            [self.userDelegate textViewDeleteBackward:self];
        }
    }else {
        [super deleteBackward];
    }
}

- (NSUInteger)numberOfLinesOfText{
    return [WLInputTextView numberOfLinesForMessage:self.text];
}

+ (NSUInteger)maxCharactersPerLine{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)? 33:109;
}

+ (NSUInteger)numberOfLinesForMessage:(NSString *)text{
    return (text.length / [WLInputTextView maxCharactersPerLine]) + 1;
}

#pragma mark -- Setters
- (void)setPlaceHolder:(NSString *)placeHolder
{
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor
{
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark -- UITextView overrides
- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark -- Drawing
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];
        [self.placeHolder drawInRect:CGRectInset(rect, 7.0f, 7.5f) withAttributes:[self placeholderTextAttributes]];
    }
}

#pragma mark -- Notifications
- (void)addTextViewNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)didReceiveTextViewNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

- (void)removeTextViewNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
    
}

- (NSDictionary *)placeholderTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;
    
    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}

@end
