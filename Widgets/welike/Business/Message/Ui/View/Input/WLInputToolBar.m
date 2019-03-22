//
//  WLInputToolBar.m
//  welike
//
//  Created by luxing on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInputToolBar.h"

#define Image(str)              (str == nil || str.length == 0) ? nil : [UIImage imageNamed:str]
#define ItemW                   44                  //44
#define ItemH                   kChatInputToolBarHeight  //49
#define TextViewH               36
#define TextViewVerticalOffset  (ItemH-TextViewH)/2.0
#define TextViewMargin          8

#define TextViewMaxLines        4.6
#define SingleWordWidth         20


@interface WLInputToolBar () <WLInputTextViewDelegate>

@property (nonatomic, strong) UIButton *picButton;

@property (nonatomic, strong) UIButton *emotionButton;

@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) WLInputTextView *textView;

@property CGFloat previousTextViewHeight;

/** 临时记录输入的textView */
@property (nonatomic, copy) NSString *currentText;

@end

@implementation WLInputToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 0.8f;
//        self.layer.shadowRadius = 3.f;
//        self.layer.shadowOffset = CGSizeMake(4,4);
//        self.image = [AppContext getImageForKey:@"msg_bar_bg"];
        
        self.picButton = [[UIButton alloc] initWithFrame:CGRectMake(kInputToolBarPicLeftPading, kInputToolBarPicTopPading, kInputToolBarPicButtonSize, kInputToolBarPicButtonSize)];
        [self.picButton setImage:[AppContext getImageForKey:@"msg_pic"] forState:UIControlStateNormal];
        [self.picButton addTarget:self action:@selector(clickedPicButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.picButton];
        self.emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-kInputToolBarSendButtonRightPading-kInputToolBarEmotionButtonSize, kInputToolBarEmotionTopPading, kInputToolBarEmotionButtonSize, kInputToolBarEmotionButtonSize)];
        [self.emotionButton setImage:[AppContext getImageForKey:@"msg_emotion"] forState:UIControlStateNormal];
        [self.emotionButton addTarget:self action:@selector(clickedEmotionButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.emotionButton];
        self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-kInputToolBarSendButtonRightPading-kInputToolBarSendButtonSize, kInputToolBarSendButtonTopPading, kInputToolBarSendButtonSize, kInputToolBarSendButtonSize)];
        self.sendButton.hidden = YES;
        [self.sendButton setImage:[AppContext getImageForKey:@"msg_send"] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        self.textView = [[WLInputTextView alloc] init];
        self.textView.frame = CGRectMake(kInputToolBarPicLeftPading+kInputToolBarPicButtonSize+kInputToolBarTextViewLeftPading, kInputToolBarTextViewTopPading, kInputToolBarTextViewMaxRightPading, kInputToolBarTextViewHeight);
        self.textView.delegate = self;
        self.textView.userDelegate = self;
        self.previousTextViewHeight = 36;
//        [self.textView setBackgroundColor:[UIColor redColor]];
//        [self setBackgroundColor:[UIColor greenColor]];
        [self addSubview:self.textView];
        [self addObserver:self forKeyPath:@"self.textView.contentSize" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

#pragma mark - events

- (void)clickedPicButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(inputToolBarPressedPicButton:keyBoardState:)])
    {
        [self.delegate inputToolBarPressedPicButton:self keyBoardState:NO];
    }
}

- (void)clickedEmotionButton:(UIButton *)sender
{
    self.emotionButton.selected = !self.emotionButton.selected;
    BOOL keyBoardChanged = YES;
    if (sender.selected)
    {
        if (!self.textView.isFirstResponder)
        {
            keyBoardChanged = NO;
        }
        [self.textView resignFirstResponder];
    }
    else
    {
        [self.textView becomeFirstResponder];
    }

    [self resumeTextViewContentSize];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.textView.hidden = NO;
    } completion:nil];

    if ([self.delegate respondsToSelector:@selector(inputToolBar:emotionButtonPressed:keyBoardState:)])
    {
        [self.delegate inputToolBar:self emotionButtonPressed:sender.selected keyBoardState:keyBoardChanged];
    }
}

- (void)clickedSendButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(inputToolBar:sendButton:keyBoardState:)])
    {
        [self.delegate inputToolBar:self sendButton:self.textView.text keyBoardState:NO];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.picButton.frame = CGRectMake(kInputToolBarPicLeftPading, CGRectGetHeight(self.frame)-kInputToolBarPicTopPading-kInputToolBarPicButtonSize, kInputToolBarPicButtonSize, kInputToolBarPicButtonSize);
    if (!self.sendButton.hidden) {
        self.sendButton.frame = CGRectMake(CGRectGetWidth(self.frame)-kInputToolBarSendButtonRightPading-kInputToolBarSendButtonSize, CGRectGetHeight(self.frame)-kInputToolBarSendButtonTopPading-kInputToolBarSendButtonSize, kInputToolBarSendButtonSize, kInputToolBarSendButtonSize);
        self.emotionButton.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame)-kInputToolBarEmotionLeftPading-kInputToolBarEmotionButtonSize,CGRectGetHeight(self.frame)- kInputToolBarEmotionTopPading-kInputToolBarEmotionButtonSize, kInputToolBarEmotionButtonSize, kInputToolBarEmotionButtonSize);
    } else {
        self.emotionButton.frame = CGRectMake(CGRectGetWidth(self.frame)-kInputToolBarSendButtonRightPading-kInputToolBarEmotionButtonSize, CGRectGetHeight(self.frame)- kInputToolBarEmotionTopPading-kInputToolBarEmotionButtonSize, kInputToolBarEmotionButtonSize, kInputToolBarEmotionButtonSize);
    }
    self.textView.frame = CGRectMake(kInputToolBarPicLeftPading+kInputToolBarPicButtonSize+kInputToolBarTextViewLeftPading, kInputToolBarTextViewTopPading,CGRectGetMinX(self.emotionButton.frame)-kInputToolBarEmotionLeftPading-kInputToolBarTextViewLeftPading-CGRectGetMaxX(self.picButton.frame), CGRectGetHeight(self.frame)-2*kInputToolBarTextViewTopPading);
}

#pragma mark -- dealloc

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.textView.contentSize"];
}

#pragma mark - 调整文本内容

- (void)setTextViewContent:(NSString *)text
{
    self.currentText = self.textView.text = text;
    [self showSendButtonIfNeeded];
}

- (void)clearTextViewContent
{
    self.currentText = self.textView.text = @"";
    [self showSendButtonIfNeeded];
}

#pragma mark - 调整placeHolder

- (void)setTextViewPlaceHolder:(NSString *)placeholder
{
    if (placeholder == nil) {
        return;
    }
    self.textView.placeHolder = placeholder;
}

- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor
{
    if (placeHolderColor == nil) {
        return;
    }
    self.textView.placeHolderTextColor = placeHolderColor;
}

#pragma mark -- 重新配置各个按钮
- (void)prepareForBeginComment
{
    self.emotionButton.selected = NO;
    self.textView.hidden = NO;
}
- (void)prepareForEndComment
{
    self.emotionButton.selected = NO;
    self.textView.hidden = NO;
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark -- UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.emotionButton.selected = NO;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputToolBarTextViewDidBeginEditing:)])
    {
        [self.delegate inputToolBarTextViewDidBeginEditing:self.textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if ([self.delegate respondsToSelector:@selector(inputToolBarSendText:)])
        {
            self.currentText = @"";
            
            [self.delegate inputToolBarSendText:textView.text];
        }
        return NO;
    }
    return YES;
}

- (void)showSendButtonIfNeeded
{
    if (self.currentText.length > 0) {
        if (self.sendButton.hidden) {
            self.sendButton.hidden = NO;
            [self setNeedsLayout];
        }
    } else {
        self.sendButton.hidden = YES;
        [self setNeedsLayout];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.currentText = textView.text;
    [self showSendButtonIfNeeded];
    if ([self.delegate respondsToSelector:@selector(inputToolBarTextViewDidChange:)])
    {
        [self.delegate inputToolBarTextViewDidChange:self.textView];
    }
}

- (void)textViewDeleteBackward:(WLInputTextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputToolBarTextViewDeleteBackward:)]) {
        
        [self.delegate inputToolBarTextViewDeleteBackward:textView];
    }
}

#pragma mark - kvo回调

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"self.textView.contentSize"]) {
        [self layoutAndAnimateTextView:self.textView];
        [self setNeedsLayout];
    }
}

#pragma mark -- 私有方法

- (void)adjustTextViewContentSize
{
    //调整 textView和recordBtn frame
    self.currentText = self.textView.text;
    self.textView.text = @"";
    self.textView.contentSize = CGSizeMake(CGRectGetWidth(self.textView.frame), TextViewH);
}

- (void)resumeTextViewContentSize
{
    self.textView.text = self.currentText;
}

#pragma mark -- 计算textViewContentSize改变

- (CGFloat)getTextViewContentH:(WLInputTextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

- (CGFloat)fontWidth
{
    return SingleWordWidth; //16号字体
}

- (CGFloat)maxLines
{
    return TextViewMaxLines;
}

- (void)layoutAndAnimateTextView:(WLInputTextView *)textView
{
    CGFloat maxHeight = [self fontWidth] * [self maxLines];
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewHeight;
    CGFloat changeInHeight = contentH - self.previousTextViewHeight;
    
    if (!isShrinking && (self.previousTextViewHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                             CGRect inputViewFrame = self.frame;
                             self.frame = CGRectMake(0.0f,
                                                     0, //inputViewFrame.origin.y - changeInHeight
                                                     inputViewFrame.size.width,
                                                     (inputViewFrame.size.height + changeInHeight));
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        self.previousTextViewHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    //动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.textView.frame;
    
    NSUInteger numLines = MAX([self.textView numberOfLinesOfText],
                              [[self.textView.text componentsSeparatedByString:@"\n"] count] + 1);
    
    
    self.textView.frame = CGRectMake(prevFrame.origin.x, prevFrame.origin.y, prevFrame.size.width, prevFrame.size.height + changeInHeight);
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >=6 ? 4.0f : 0.0f), 0.0f, (numLines >=6 ? 4.0f : 0.0f), 0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    //self.messageInputTextView.scrollEnabled = YES;
    if (numLines >3) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height-self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length-2, 1)];
    }
}

@end
