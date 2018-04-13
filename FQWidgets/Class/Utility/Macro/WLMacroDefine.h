//
//  CCMacroDefine.h
//  chongchongtv
//
//  Created by fanqi on 2017/8/17.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#ifndef WLMacroDefine_h
#define WLMacroDefine_h

#define kMaxVideoRecordDuration      10.0

// App全局frame
#define kMainToastViewHeight    kSizeScale(64)
#define kMainTopViewHeight      kSizeScale(100)
#define kMarginX                kSizeScale(30)
#define kMarginY                kSizeScale(28)
#define kPaddingX               kSizeScale(18)
#define kPaddingY               kSizeScale(15)

// image size
#define kBigImageSize           kSizeScale(90)
#define kSmallImageSize         kSizeScale(50)

#pragma mark - BackgroundColor

#define kMainColor              kUIColorFromRGB(0xFFE200)

#pragma mark - Font
// font color
#define kHeaderFontColor        kUIColorFromRGB(0x313131)
#define kNameFontColor          kUIColorFromRGB(0x313131)
#define kBodyFontColor          kUIColorFromRGB(0x626262)
#define kDateTimeFontColor      kUIColorFromRGB(0xAFB0B1)
#define kLinkFontColor          kUIColorFromRGB(0x2B98EE)
#define kLightFontColor         kUIColorFromRGB(0xC4C4C4)

// font size
#define kHeaderFontSize         kSizeScale(20)
#define kNameFontSize           kSizeScale(16)
#define kBodyFontSize           kSizeScale(17)
#define kDateTimeFontSize       kSizeScale(12)
#define kLinkFontSize           kSizeScale(14)
#define kLightFontSize          kSizeScale(12)

// font
#define kMediumFont(size)       [UIFont systemFontOfSize:size weight:UIFontWeightMedium]
#define kNavBarTitleFont        kMediumFont(kHeaderFontSize)
#define kNameFont               kMediumFont(kNameFontSize)
#define kBodyFont               kMediumFont(kBodyFontSize)
#define kDateTimeFont           kMediumFont(kDateTimeFontSize)
#define kLinkFont               kMediumFont(kLinkFontSize)

#endif /* WLMacroDefine_h */
