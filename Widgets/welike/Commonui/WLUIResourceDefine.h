//
//  WLUIResourceDefine.h
//  welike
//
//  Created by 刘斌 on 2018/4/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#ifndef WLUIResourceDefine_h
#define WLUIResourceDefine_h

#define kUIColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define kUIColorFromRGB(rgbValue) (kUIColorFromRGBA(rgbValue, 1.0))
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define kMediumFont(size)   \
({  \
UIFont *font;   \
if (@available(iOS 8.2, *)) {   \
font = [UIFont systemFontOfSize:size weight:UIFontWeightMedium];  \
} else {    \
font = [UIFont systemFontOfSize:size];    \
}   \
font;   \
})

#define kRegularFont(size)   \
({  \
UIFont *font;   \
if (@available(iOS 8.2, *)) {   \
font = [UIFont systemFontOfSize:size weight:UIFontWeightRegular];  \
} else {    \
font = [UIFont systemFontOfSize:size];    \
}   \
font;   \
})

#define kBoldFont(size)   \
({  \
UIFont *font;   \
if (@available(iOS 8.2, *)) {   \
font = [UIFont systemFontOfSize:size weight:UIFontWeightBold];  \
} else {    \
font = [UIFont systemFontOfSize:size];    \
}   \
font;   \
})

#define kIsiPhoneX   \
({  \
BOOL isiPhoneX;   \
UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];\
if (@available(iOS 11.0, *)) {\
if (mainWindow.safeAreaInsets.bottom > 0.0) {\
isiPhoneX = YES;\
} \
else\
{\
    isiPhoneX = NO; \
}\
} else { \
isiPhoneX = NO; \
} \
isiPhoneX;   \
})



#define kNeedLogin      if (![AppContext getInstance].accountManager.isLogin) {\
                            [[WLLoginHintView instance] display];\
                            return;\
                        }\

#define SINGLE_LINE_WIDTH (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET ((1 / [UIScreen mainScreen].scale) / 2)

#define kCurrentWindow                      ([UIApplication sharedApplication].keyWindow)
#define kScreenBounds                       ([UIScreen mainScreen].bounds)
#ifndef kScreenWidth
#define kScreenWidth                        ([UIScreen mainScreen].bounds.size.width)
#endif
#ifndef kScreenHeight
#define kScreenHeight                       ([UIScreen mainScreen].bounds.size.height)
#endif
#ifndef kScreenScale
#define kScreenScale                        ([UIScreen mainScreen].scale)
#endif

// common
#define kMainColor                          kUIColorFromRGB(0xFF9300)  //橙色主色调
#define kDeepOrangeColor                    kUIColorFromRGB(0xFF7400)
#define kMainPressColor                     kUIColorFromRGB(0xFF9300)
#define kClickableTextColor                 kUIColorFromRGB(0x48779D)  // kUIColorFromRGB(0x2B98EE)
#define kSeparateLineColor                  kUIColorFromRGB(0xF5F5F5)  //cell分割线
#define kLargeBtnDisableColor               kUIColorFromRGB(0xEDEDED)  //按钮背景不可用颜色
#define kMarkViewColor                      kUIColorFromRGB(0xFF5500)
#define kLightBackgroundViewColor           kUIColorFromRGB(0xF6F6F6)  //默认背景色
#define kPlaceHolderColor                   kUIColorFromRGB(0xAFB0B1)  //placeHolder 颜色
#define kNavbarColor                        kUIColorFromRGB(0xFFFFFF)  //导航栏颜色
#define kNavShadowColor                     kUIColorFromRGB(0xDDDDDD)  //导航栏分割线
#define kNavbarTitleColor                   kUIColorFromRGB(0x313131)  //导航栏标题色
#define kDescriptionColor                   kUIColorFromRGB(0xAFB0B1)  //list中描述的文字颜色
#define kDialogFontColor                    kUIColorFromRGB(0x313131)
#define kSearchEditorColor                  kUIColorFromRGB(0xEEEEEE)
#define kLabelBgColor                       kUIColorFromRGB(0xF8F8F8)
#define kTableViewBgColor                   kUIColorFromRGB(0xF8F8F8)


// font color
#define kCommonBtnTextColor                 kUIColorFromRGB(0xFFFFFF)
#define kCommonBtnDisableTextColor          kUIColorFromRGB(0xAFB0B1)
#define kPublishEditColor                   kUIColorFromRGB(0x626262)
#define kNameFontColor                      kUIColorFromRGB(0x313131)
#define kBodyFontColor                      kUIColorFromRGB(0x626262)
#define kDescFontColor                      kUIColorFromRGB(0x5C5C5C)
#define kDateTimeFontColor                  kUIColorFromRGB(0xAFB0B1)
#define kLightLightFontColor                kUIColorFromRGB(0xAFB0B1)
#define kRichContentNormalColor             kUIColorFromRGB(0x313131)
#define kRichFontColor                      kUIColorFromRGB(0x48779D)
#define kRichHightFontColor                 kUIColorFromRGB(0xCFEBFF)
#define kLightFontColor                     kUIColorFromRGB(0xC4C4C4)
#define kWeightTitleFontColor               kUIColorFromRGB(0x423D2D)
#define kEmptyContentFontColor              kUIColorFromRGB(0xC2C2C2)
#define kDarkFontCOlor                      kUIColorFromRGB(0xA1A1A1)

// register font color
#define kErrorNoteFontColor                 kUIColorFromRGB(0xFF4B52)
#define kGenderFontColor                    kUIColorFromRGB(0xAAAAAA)
#define kFacebookFontColor                  kUIColorFromRGB(0x3B5998)
#define kGoogleFontColor                    kUIColorFromRGB(0xDE4330)

// setting
#define kSettingRightContentFontColor       kUIColorFromRGB(0xA9A9A9)
#define kSettingLogoutBtnColor              kUIColorFromRGB(0xFF6A49)

// search
#define kSearchSugContentFontColor          kUIColorFromRGB(0x454545)
#define kSearchPagerFocusedColor            kUIColorFromRGB(0xFFA00B)
#define kSearchTextColor                    kUIColorFromRGB(0x313131)
#define kSearchBtnBg                        kUIColorFromRGB(0xF8F8F8)
#define kSearchBorder                       kUIColorFromRGB(0xF4F4F4)
#define sectionColor                        kUIColorFromRGB(0xF9F9F9)
#define searchBarBg                         kUIColorFromRGB(0xF6F6F6)
#define searchCancel                        kUIColorFromRGB(0x313131)
#define topic_detail                        kUIColorFromRGB(0xAFB0B1)
#define topic_section_view_detail           kUIColorFromRGB(0xAFB0B1)
#define lbs_detail                          kUIColorFromRGB(0xAFB0B1)

// refresh bar
#define kRefreshProgressColor               kUIColorFromRGB(0x423D2D)

//publish ui
#define send_text_color_disable             kUIColorFromRGB(0xAFB0B1)
#define send_text_color_enable              kUIColorFromRGB(0xFFFFFF)
#define videoThumbBg                        kUIColorFromRGB(0xE8E8E8)
#define charNumColorGrey                    kUIColorFromRGB(0xAFB0B1)
#define charNumColorOrange                  kUIColorFromRGB(0xFF9A00)
#define charNumColorRed                     kUIColorFromRGB(0xFF6A49)
#define topic_flag                          kUIColorFromRGB(0x423D2D)
#define postCardFrameColor                  kUIColorFromRGB(0xE1E1E1)
#define kBorderLineColor                    kUIColorFromRGB(0xEEEEEE)
//#define kBottomFontColor                    kUIColorFromRGB(0xD8D8D8)


#define thumbBgColor                        kUIColorFromRGB(0xAFB0B1)
//draft ui
#define kDefaultThumbBgColor                kUIColorFromRGB(0xD8D8D8)
#define kDraftRichTextColor                 kUIColorFromRGB(0x626262)

// im
#define kChatContentColor                   kUIColorFromRGB(0x6B675A)

//artical
#define kArticalTitleColor                  kUIColorFromRGB(0x4A4A4A)
#define kArticalSecondTitleColor            kUIColorFromRGB(0xAFB0B1)

// font size
#define kNoteFontSize                       15.f
#define kErrorNoteFontSize                  13.f
#define kNameFontSize                       16.f
#define kMediumNameFontSize                 14.f
#define kBodyFontSize                       17.f
#define kDateTimeFontSize                   10.f
#define kLinkFontSize                       14.f
#define kLightFontSize                      12.f
#define kSmallBadgeNumFontSize              11.f
#define kChatContentFontSize                13.f

// common ui
#define kSystemStatusBarHeight              [UIApplication sharedApplication].statusBarFrame.size.height
#define kSingleNavBarHeight                 44.f
#define kNavBarHeight                       (kSystemStatusBarHeight + kSingleNavBarHeight)
#define kSearchBarHeight                    44.f
#define kSafeAreaBottomConstHeight          34.f
#define kSingleTabBarHeight                 48.f
#define kTabBarHeight                       (kIsiPhoneX ? (kSafeAreaBottomConstHeight + kSingleTabBarHeight) : kSingleTabBarHeight)
#define kSafeAreaBottomY                    (kIsiPhoneX ? kSafeAreaBottomConstHeight : 0)
#define kLargeBtnHeight                     40.f
#define kLargeBtnXMargin                    20.f
#define kLargeBtnYMargin                    16.f
#define kLargeBtnRadius                     4.f
#define kTextFieldHeight                    37.f
#define kErrorNoteHeight                    15.f
#define kCommonCellMarginY                  10.0
#define kCommonCellSpacing                  8.0

// setting ui
#define kSettingCellMarginX                 12.f
#define kSettingCellHeight                  48.f

// register ui
#define kRegisterLogoTopMargin_larg         131.f
#define kRegisterLogoTopMargin_smal         91.f
#define kRegisterLeftMargin                 25.f

// search ui
#define kSearchCellLeftMargin               15.f

// publish ui
#define bottom_bar_btn_size                 CGSizeMake(44, 44)

// im ui
#define kChatCellHeight                     71.f

// avatar
#define kAvatarSizeLarge                 72.0
#define kAvatarSizeMedium                40.0
#define kAvatarSizeSmall                 32.0
#define kAvatarSizeMin                   28.0

// cornerRadius
#define kCornerRadius                    4.0

#pragma mark - ******************* 自定义TODO *******************

#define STRINGIFY(S) #S
#define DEFER_STRINGIFY(S) STRINGIFY(S)
#define PRAGMA_MESSAGE(MSG) _Pragma(STRINGIFY(message(MSG)))
#define FORMATTED_MESSAGE(MSG) "[TODO-" DEFER_STRINGIFY(__COUNTER__) "] " MSG " \n" \
DEFER_STRINGIFY(__FILE__) " line " DEFER_STRINGIFY(__LINE__)
#define KEYWORDIFY @try {} @catch (...) {}
#define TODO(MSG) KEYWORDIFY PRAGMA_MESSAGE(FORMATTED_MESSAGE(MSG))


#define emojiRegular   @"\\[[a-zA-Z0-9_]+\\]"
#define linkRegular   @"(http|https)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]"

#ifdef DEBUG

#else
#define NSLog(FORMAT, ...) nil
#endif

#define WLLog(FORMAT, ...) NSLog(@"LOG >> Function:%s Line:%d Content:%@\n", __FUNCTION__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])


#endif /* WLUIResourceDefine_h */
