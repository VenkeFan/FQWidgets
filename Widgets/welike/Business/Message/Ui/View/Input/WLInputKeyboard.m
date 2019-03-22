//
//  WLInputKeyboard.m
//  welike
//
//  Created by luxing on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInputKeyboard.h"

@interface WLInputKeyboard () <WLInputToolBarDelegate,WLEmoticonInputViewDelegate>
{
    __weak UITableView *_associateTableView;    //chatKeyBoard关联的表
}

@property (nonatomic, strong) WLInputToolBar *chatToolBar;
@property (nonatomic, strong) WLEmoticonInputView *emotionInputView;

/**
 *  聊天键盘 上一次的 y 坐标
 */
@property (nonatomic, assign) CGFloat lastChatKeyboardY;

@end

@implementation WLInputKeyboard

#pragma mark -- life

+ (instancetype)keyBoard
{
    return [[self alloc] initWithFrame:CGRectMake(0,kSafeAreaHeight-kInputToolBarHeight, kScreenWidth,kInputKeyBoardHeight)];
}

+ (instancetype)keyBoardWithParentViewBounds:(CGRect)bounds
{
    CGRect frame = CGRectMake(0, bounds.size.height - kInputToolBarHeight, kScreenWidth, kInputKeyBoardHeight);
    return [[self alloc] initWithFrame:frame];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [self removeObserver:self forKeyPath:@"self.chatToolBar.frame"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _chatToolBar = [[WLInputToolBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kInputToolBarHeight)];
        _chatToolBar.delegate = self;
        [self addSubview:_chatToolBar];
        _emotionInputView = [[WLEmoticonInputView alloc] init];
        _emotionInputView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kEmotionInputViewHeight, kScreenWidth, kEmotionInputViewHeight);
        _emotionInputView.delegate = self;
        self.emotionInputView.hidden = YES;
        [self addSubview:_emotionInputView];
        
        self.lastChatKeyboardY = frame.origin.y;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self addObserver:self forKeyPath:@"self.chatToolBar.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

#pragma mark - UIKeyboardWillChangeFrameNotification

- (void)keyBoardWillChangeFrame:(NSNotification *)notification
{
    // 键盘已经弹起时，表情按钮被选择
    if (self.chatToolBar.emotionButton.selected)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.emotionInputView.hidden = NO;
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, kSafeAreaHeight-CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.emotionInputView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kEmotionInputViewHeight, CGRectGetWidth(self.frame), kEmotionInputViewHeight);//
            [self updateAssociateTableViewFrame];

        } completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.emotionInputView.hidden = YES;
            CGRect begin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

            CGFloat targetY = end.origin.y - CGRectGetHeight(self.chatToolBar.frame);
            if(begin.size.height>=0 && (begin.origin.y-end.origin.y>0))
            {
                // 键盘弹起 (包括，第三方键盘回调三次问题，监听仅执行最后一次)
                if(![self.chatToolBar.textView isFirstResponder]) {
                    [self.chatToolBar.textView becomeFirstResponder];
                }
                self.lastChatKeyboardY = self.frame.origin.y;
                self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                self.emotionInputView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kEmotionInputViewHeight);
                [self updateAssociateTableViewFrame];

            }
            else if (end.origin.y == kScreenHeight && begin.origin.y!=end.origin.y && duration > 0)
            {
                self.lastChatKeyboardY = self.frame.origin.y;
                targetY -= kSafeAreaBottomY;
                //键盘收起
                if (self.keyBoardStyle == KeyBoardStyleChat)
                {
                    self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);

                }else if (self.keyBoardStyle == KeyBoardStyleComment)
                {
                    self.frame = CGRectMake(0, [self getSuperViewH], CGRectGetWidth(self.frame), self.frame.size.height);
                }
                [self updateAssociateTableViewFrame];

            }
            else
                if ((begin.origin.y-end.origin.y<0) && duration == 0)
            {
                self.lastChatKeyboardY = self.frame.origin.y;
                //键盘切换
                self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                [self updateAssociateTableViewFrame];
            }
        }];
    }
}

/**
 *  调整关联的表的高度
 */
- (void)updateAssociateTableViewFrame
{
    //表的原来的偏移量
    CGFloat original =  _associateTableView.contentOffset.y;
    
    //键盘的y坐标的偏移量
    CGFloat keyboardOffset = self.frame.origin.y - self.lastChatKeyboardY;
    
    //更新表的frame
    CGRect frame = _associateTableView.frame;
    frame.size.height = self.frame.origin.y-kNavBarHeight;
    _associateTableView.frame = frame;
    
    //表的超出frame的内容高度
    CGFloat tableViewContentDiffer = _associateTableView.contentSize.height - _associateTableView.frame.size.height;
    
    
    //是否键盘的偏移量，超过了表的整个tableViewContentDiffer尺寸
    CGFloat offset = 0;
    if (fabs(tableViewContentDiffer) > fabs(keyboardOffset)) {
        offset = original-keyboardOffset;
    }else {
        offset = tableViewContentDiffer;
    }
    
    if (_associateTableView.contentSize.height +_associateTableView.contentInset.top+_associateTableView.contentInset.bottom> _associateTableView.frame.size.height) {
        _associateTableView.contentOffset = CGPointMake(0, offset);
    }
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"self.chatToolBar.frame"]) {
        
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldRect = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGFloat changeHeight = newRect.size.height - oldRect.size.height;
        
        self.lastChatKeyboardY = self.frame.origin.y;
        self.frame = CGRectMake(0, self.frame.origin.y - changeHeight, self.frame.size.width, self.frame.size.height + changeHeight);
        self.emotionInputView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kEmotionInputViewHeight, CGRectGetWidth(self.frame), kEmotionInputViewHeight);
        [self updateAssociateTableViewFrame];
    }
}

#pragma mark WLEmoticonInputViewDelegate

- (void)emoticonInputDidTapText:(NSString *)text
{
    NSString *emotionText = [NSString stringWithFormat:@"[%@]",text];
    emotionText = [self.chatToolBar.textView.text stringByAppendingString:emotionText];
    [self.chatToolBar setTextViewContent:emotionText];
}

- (void)emoticonInputDidTapBackspace
{
    NSString *text = self.chatToolBar.textView.text;
    if (text.length > 0) {
        [self deleteBackward:text appendText:@""];
    }
}

#pragma mark - WLInputToolBarDelegate
/**
 *  表情按钮选中，此刻键盘没有弹起
 *  @param change  键盘是否弹起
 */
- (void)inputToolBar:(WLInputToolBar *)toolBar emotionButtonPressed:(BOOL)select keyBoardState:(BOOL)change
{
    if (select && change == NO)
    {
        self.emotionInputView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, kSafeAreaHeight-CGRectGetHeight(self.frame), kScreenWidth, CGRectGetHeight(self.frame));
            self.emotionInputView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kEmotionInputViewHeight, CGRectGetWidth(self.frame), kEmotionInputViewHeight);
            [self updateAssociateTableViewFrame];
            
        }];
    }
}

- (void)inputToolBar:(WLInputToolBar *)toolBar sendButton:(NSString *)text keyBoardState:(BOOL)change
{
    [self inputToolBarSendText:text];
}

- (void)inputToolBarPressedPicButton:(WLInputToolBar *)toolBar keyBoardState:(BOOL)change
{
    [self keyboardDown];
    if ([self.delegate respondsToSelector:@selector(inputKeyBoardPressedPicButton)]) {
        [self.delegate inputKeyBoardPressedPicButton];
    }
}

- (void)inputToolBarTextViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputKeyBoardTextViewDidBeginEditing:)]) {
        [self.delegate inputKeyBoardTextViewDidBeginEditing:textView];
    }
}

- (void)inputToolBarSendText:(NSString *)text
{
    [self.chatToolBar clearTextViewContent];
    if ([self.delegate respondsToSelector:@selector(inputKeyBoardSendText:)]) {
        [self.delegate inputKeyBoardSendText:text];
    }
}

- (void)inputToolBarTextViewDidChange:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputKeyBoardTextViewDidChange:)]) {
        [self.delegate inputKeyBoardTextViewDidChange:textView];
    }
}

- (void)inputToolBarTextViewDeleteBackward:(WLInputTextView *)textView
{
    NSRange range = textView.selectedRange;
    NSString *handleText;
    NSString *appendText;
    if (range.location == textView.text.length) {
        handleText = textView.text;
        appendText = @"";
    }else {
        handleText = [textView.text substringToIndex:range.location];
        appendText = [textView.text substringFromIndex:range.location];
    }
    
    if (handleText.length > 0) {
        
        [self deleteBackward:handleText appendText:appendText];
    }
}

#pragma mark -- set方法
- (void)setAssociateTableView:(UITableView *)associateTableView
{
    if (_associateTableView != associateTableView) {
        _associateTableView = associateTableView;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    
    [self.chatToolBar setTextViewPlaceHolder:placeHolder];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor = placeHolderColor;
    
    [self.chatToolBar setTextViewPlaceHolderColor:placeHolderColor];
}

- (void)setKeyBoardStyle:(KeyBoardStyle)keyBoardStyle
{
    _keyBoardStyle = keyBoardStyle;
    
    if (keyBoardStyle == KeyBoardStyleComment) {
        self.lastChatKeyboardY = self.frame.origin.y;
        self.frame = CGRectMake(0, self.frame.origin.y+kInputToolBarHeight, self.frame.size.width, self.frame.size.height);
    }
}

- (void)keyboardUp
{
    if (self.keyBoardStyle == KeyBoardStyleChat)
    {
        [self.chatToolBar prepareForBeginComment];
        [self.chatToolBar.textView becomeFirstResponder];
    }
}

- (void)keyboardDown
{
    if (self.keyBoardStyle == KeyBoardStyleChat)
    {
        if ([self.chatToolBar.textView isFirstResponder])
        {
            [self.chatToolBar.textView resignFirstResponder];
        }
        else
        {
            if((kSafeAreaHeight- CGRectGetMinY(self.frame)) > self.chatToolBar.frame.size.height)
            {
                self.chatToolBar.emotionButton.selected = NO;
                self.emotionInputView.hidden = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    
                    self.lastChatKeyboardY = self.frame.origin.y;
                    CGFloat y = self.frame.origin.y;
                    y = kSafeAreaHeight - self.chatToolBar.frame.size.height;
                    self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
                    
                    [self updateAssociateTableViewFrame];
                    
                }];
            }
        }
    }
}

- (void)keyboardUpforComment
{
    [self.chatToolBar prepareForBeginComment];
    [self.chatToolBar.textView becomeFirstResponder];
}

- (void)keyboardDownForComment
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

        self.lastChatKeyboardY = self.frame.origin.y;

        [self.chatToolBar prepareForEndComment];
        self.frame = CGRectMake(0, [self getSuperViewH], self.frame.size.width, CGRectGetHeight(self.frame));

        [self updateAssociateTableViewFrame];

    } completion:nil];
}

- (CGFloat)getSuperViewH
{
    return self.superview.frame.size.height;
}

#pragma mark - 回删表情或文字

- (void)deleteBackward:(NSString *)text appendText:(NSString *)appendText
{
    if (IsTextContainFace(text)) { // 如果最后一个是表情
        
        NSRange startRang = [text rangeOfString:@"[" options:NSBackwardsSearch];
        NSString *current = [text substringToIndex:startRang.location];
        [self.chatToolBar setTextViewContent:[current stringByAppendingString:appendText]];
        self.chatToolBar.textView.selectedRange = NSMakeRange(current.length, 0);
        
    }else { // 如果最后一个系统键盘输入的文字
        
        if (text.length >= 2) {
            
            NSString *tempString = [text substringWithRange:NSMakeRange(text.length - 2, 2)];
            
            if ([tempString isEmoji]) { // 如果是Emoji表情
                NSString *current = [text substringToIndex:text.length - 2];
                
                [self.chatToolBar setTextViewContent:[current stringByAppendingString:appendText]];
                self.chatToolBar.textView.selectedRange = NSMakeRange(current.length, 0);
                
            }else { // 如果是纯文字
                NSString *current = [text substringToIndex:text.length - 1];
                [self.chatToolBar setTextViewContent:[current stringByAppendingString:appendText]];
                self.chatToolBar.textView.selectedRange = NSMakeRange(current.length, 0);
            }
            
        }else { // 如果是纯文字
            
            NSString *current = [text substringToIndex:text.length - 1];
            [self.chatToolBar setTextViewContent:[current stringByAppendingString:appendText]];
            self.chatToolBar.textView.selectedRange = NSMakeRange(current.length, 0);
        }
    }
}

@end

@implementation NSString (Emoji)

- (BOOL)isEmoji{
    const unichar high = [self characterAtIndex:0];
    
    // Surrogate pair (U+1D000-1F77F)
    if (0xd800 <= high && high <= 0xdbff && self.length >= 2) {
        const unichar low = [self characterAtIndex:1];
        const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
        
        return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
        
        // Not surrogate pair (U+2100-27BF)
    } else {
        return (0x2100 <= high && high <= 0x27bf);
    }
}

@end
