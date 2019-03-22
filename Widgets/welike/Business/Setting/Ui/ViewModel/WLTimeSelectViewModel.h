//
//  WLTimeSelectViewModel.h
//  welike
//
//  Created by luxing on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotificationSettingTimeColor                    kUIColorFromRGB(0x2B98EE)
#define kNotificationSettingTimeTitleColor               kUIColorFromRGB(0xAFB0B1)

@interface WLTimeSelectViewModel : NSObject

@property (nonatomic, copy) NSString *fromTitle;
@property (nonatomic, copy) NSString *toTitle;
@property (nonatomic, assign) NSUInteger fromHours;
@property (nonatomic, assign) NSUInteger fromMinute;
@property (nonatomic, assign) NSUInteger toHours;
@property (nonatomic, assign) NSUInteger toMinute;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, assign) BOOL isTail;

@end
