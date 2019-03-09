//
//  CCMacroDefine.h
//  chongchongtv
//
//  Created by fanqi on 2017/8/17.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#ifndef WLMacroDefine_h
#define WLMacroDefine_h

#pragma mark - Other

#define kMaxVideoRecordDuration         10.0
#define kMaxVideoUploadQuality          5.0

#pragma mark - BackgroundColor

#define kMainColor              kUIColorFromRGB(0xFFE200)

#pragma mark - Font
// font color
#define kHeaderFontColor        kUIColorFromRGB(0x313131)
#define kNameFontColor          kUIColorFromRGB(0x313131)
#define kBodyFontColor          kUIColorFromRGB(0x626262)
#define kDescFontColor          kUIColorFromRGB(0x5C5C5C)
#define kDateTimeFontColor      kUIColorFromRGB(0xAFB0B1)
#define kLinkFontColor          kUIColorFromRGB(0x2B98EE)
#define kLightFontColor         kUIColorFromRGB(0xC4C4C4)

// font size
#define kHeaderFontSize         kSizeScale(20)
#define kNameFontSize           kSizeScale(16)
#define kBodyFontSize           kSizeScale(17)
#define kDescFontSize           kSizeScale(15)
#define kDateTimeFontSize       kSizeScale(12)
#define kLinkFontSize           kSizeScale(14)
#define kLightFontSize          kSizeScale(12)

// font

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


#define kNavBarTitleFont        kMediumFont(kHeaderFontSize)
#define kNameFont               kMediumFont(kNameFontSize)
#define kBodyFont               kMediumFont(kBodyFontSize)
#define kDescFont               kMediumFont(kDescFontSize)
#define kDateTimeFont           kMediumFont(kDateTimeFontSize)
#define kLinkFont               kMediumFont(kLinkFontSize)

#endif /* WLMacroDefine_h */
