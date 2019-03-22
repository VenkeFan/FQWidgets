//
//  WLInputTextView.h
//  welike
//
//  Created by luxing on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTextViewDefaultPlaceHolderColor                     kUIColorFromRGB(0xD7D7D7)
#define kTextViewDefaultTextColor                            kUIColorFromRGB(0x313131)
#define kTextViewDefaultFillColor                            kUIColorFromRGB(0xF6F6F6)
#define kTextViewNoticeFillColor                             kUIColorFromRGB(0xFFEDE9)
#define kTextViewNoticeBorderColor                           kUIColorFromRGB(0xFF5500)

#define kTextViewDefaultFontSize                             16.0f
#define kTextViewCornerRadius                                4.0f
#define kTextViewBorderWidth                                 0.65f

/**  判断文字中是否包含表情 */
#define IsTextContainFace(text) [text containsString:@"["] &&  [text containsString:@"]"] && [[text substringFromIndex:text.length - 1] isEqualToString:@"]"]

/** 判断emoji下标 */
#define emojiText(text)  (text.length >= 2) ? [text substringFromIndex:text.length - 2] : [text substringFromIndex:0]

//ChatKeyBoard背景颜色
#define kChatKeyBoardColor              [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0f]

////表情模块高度
//#define kFacePanelHeight                216
//#define kFacePanelBottomToolBarHeight   40
//#define kUIPageControllerHeight         25
//
////拍照、发视频等更多功能模块的面板的高度
//#define kMorePanelHeight                216
//#define kMoreItemH                      80
//#define kMoreItemIconSize               60
//
//
////整个聊天工具的高度
//#define kChatKeyBoardHeight     kChatToolBarHeight + kFacePanelHeight

#define isIPhone4_5                (kScreenWidth == 320)
#define isIPhone6_6s               (kScreenWidth == 375)
#define isIPhone6p_6sp             (kScreenWidth == 414)

@class WLInputTextView;

@protocol WLInputTextViewDelegate <UITextViewDelegate>

- (void)textViewDeleteBackward:(WLInputTextView *)textView;

@end

@interface WLInputTextView : UITextView

@property (nonatomic ,weak) id<WLInputTextViewDelegate> userDelegate;

@property (nonatomic, copy) NSString * placeHolder;

@property (nonatomic, strong) UIColor * placeHolderTextColor;

- (NSUInteger)numberOfLinesOfText;

@end
