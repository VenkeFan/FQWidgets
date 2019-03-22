//
//  WLTrackerLanguage.h
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLTrackerLanguageSource) {
    WLTrackerLanguageSource_Home        = 1,
    WLTrackerLanguageSource_Setting     = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerLanguage : NSObject

+ (void)appendTrackerWithLang:(NSString *)lang
                       source:(WLTrackerLanguageSource)source;

@end

NS_ASSUME_NONNULL_END
