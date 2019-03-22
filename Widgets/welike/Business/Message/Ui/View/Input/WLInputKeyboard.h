//
//  WLInputKeyboard.h
//  welike
//
//  Created by luxing on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WLInputToolBar.h"
#import "WLEmoticonInputView.h"

typedef NS_ENUM(NSInteger, KeyBoardStyle)
{
    KeyBoardStyleChat = 0,
    KeyBoardStyleComment
};

//表情模块高度
#define kEmotionInputViewHeight                216
//整个聊天工具的高度
#define kInputKeyBoardHeight     kInputToolBarHeight + kEmotionInputViewHeight
#define kSafeAreaHeight          (kScreenHeight-kSafeAreaBottomY)

@class WLInputKeyboard;
@protocol WLInputKeyboardDelegate <NSObject>
@optional
/**
 *  输入状态
 */
- (void)inputKeyBoardTextViewDidBeginEditing:(UITextView *)textView;
- (void)inputKeyBoardSendText:(NSString *)text;
- (void)inputKeyBoardPressedPicButton;
- (void)inputKeyBoardTextViewDidChange:(UITextView *)textView;

@end

@interface WLInputKeyboard : UIView

/**
 *  默认是导航栏透明，或者没有导航栏
 */
+ (instancetype)keyBoard;

/**
 *  直接传入父视图的bounds过来
 *
 *  @param bounds 父视图的bounds，一般为控制器的view
 *
 *  @return keyboard对象
 */
+ (instancetype)keyBoardWithParentViewBounds:(CGRect)bounds;

/**
 *
 *  设置关联的表
 */
@property (nonatomic, weak) UITableView *associateTableView;

@property (nonatomic, weak) id<WLInputKeyboardDelegate> delegate;

@property (nonatomic, readonly, strong) WLInputToolBar *chatToolBar;

/**
 *  设置键盘的风格
 *
 *  默认是 KeyBoardStyleChat
 */
@property (nonatomic, assign) KeyBoardStyle keyBoardStyle;

/**
 *  placeHolder内容
 */
@property (nonatomic, copy) NSString * placeHolder;
/**
 *  placeHolder颜色
 */
@property (nonatomic, strong) UIColor *placeHolderColor;

/**
 *  键盘弹出
 */
- (void)keyboardUp;

/**
 *  键盘收起
 */
- (void)keyboardDown;


/************************************************************************************************
 *  如果设置键盘风格为 KeyBoardStyleComment 则可以使用下面两个方法
 *  开启评论键盘
 */
- (void)keyboardUpforComment;

/**
 *  隐藏评论键盘
 */
- (void)keyboardDownForComment;

@end

@interface NSString (Emoji)

- (BOOL)isEmoji;

@end
