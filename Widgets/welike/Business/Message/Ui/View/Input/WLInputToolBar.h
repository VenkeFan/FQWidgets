//
//  WLInputToolBar.h
//  welike
//
//  Created by luxing on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WLInputTextView.h"

#define kInputToolBarHeight                        48.0
#define kInputToolBarPicButtonSize                 22.f
#define kInputToolBarPicLeftPading                 15.f
#define kInputToolBarPicTopPading                  13.f
#define kInputToolBarTextViewLeftPading            9.f
#define kInputToolBarTextViewTopPading             6.f
#define kInputToolBarTextViewHeight                36.f

#define kInputToolBarEmotionLeftPading             9.f
#define kInputToolBarEmotionTopPading              12.f
#define kInputToolBarEmotionButtonSize             24.f

#define kInputToolBarSendButtonRightPading         15.f
#define kInputToolBarSendButtonTopPading           12.f
#define kInputToolBarSendButtonSize                24.f

#define kInputToolBarTextViewMaxRightPading   (kInputToolBarTextViewMinRightPading+kInputToolBarSendButtonSize+kInputToolBarEmotionLeftPading)
#define kInputToolBarTextViewMinRightPading          (kInputToolBarSendButtonRightPading+kInputToolBarEmotionButtonSize+kInputToolBarEmotionLeftPading)

typedef NS_ENUM(NSInteger, ButKind)
{
    kButKindVoice,
    kButKindFace,
    kButKindMore,
    kButKindSwitchBar
};

@class WLInputToolBar;

@protocol WLInputToolBarDelegate <NSObject>

@optional

- (void)inputToolBar:(WLInputToolBar *)toolBar emotionButtonPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)inputToolBar:(WLInputToolBar *)toolBar sendButton:(NSString *)text keyBoardState:(BOOL)change;
- (void)inputToolBarPressedPicButton:(WLInputToolBar *)toolBar keyBoardState:(BOOL)change;
- (void)inputToolBarTextViewDidBeginEditing:(UITextView *)textView;
- (void)inputToolBarSendText:(NSString *)text;
- (void)inputToolBarTextViewDidChange:(UITextView *)textView;
- (void)inputToolBarTextViewDeleteBackward:(WLInputTextView *)textView;

@end


@interface WLInputToolBar : UIImageView

@property (nonatomic, weak) id<WLInputToolBarDelegate> delegate;
//
///** 切换barView按钮 */
//@property (nonatomic, readonly, strong) UIButton *switchBarBtn;
///** 语音按钮 */
//@property (nonatomic, readonly, strong) UIButton *voiceBtn;
///** 表情按钮 */
//@property (nonatomic, readonly, strong) UIButton *faceBtn;
///** more按钮 */
//@property (nonatomic, readonly, strong) UIButton *moreBtn;
///** 输入文本框 */
@property (nonatomic, readonly, strong) WLInputTextView *textView;
@property (nonatomic, readonly, strong) UIButton *emotionButton;
/** 按住录制语音按钮 */
//@property (nonatomic, readonly, strong) RFRecordButton *recordBtn;
//
///** 默认为no */
//@property (nonatomic, assign) BOOL allowSwitchBar;
///** 以下默认为yes*/
//@property (nonatomic, assign) BOOL allowVoice;
//@property (nonatomic, assign) BOOL allowFace;
//@property (nonatomic, assign) BOOL allowMoreFunc;
//
//@property (readonly) BOOL voiceSelected;
//@property (readonly) BOOL faceSelected;
//@property (readonly) BOOL moreFuncSelected;
//@property (readonly) BOOL switchBarSelected;


/**
 *  配置textView内容
 */
- (void)setTextViewContent:(NSString *)text;
- (void)clearTextViewContent;

/**
 *  配置placeHolder
 */
- (void)setTextViewPlaceHolder:(NSString *)placeholder;
- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor;

///**
// *  为开始评论和结束评论做准备
// */
- (void)prepareForBeginComment;
- (void)prepareForEndComment;


/**
 *  加载数据
 */
//- (void)loadBarItems:(NSArray<ChatToolBarItem *> *)barItems;

@end
