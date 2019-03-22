//
//  WLAuthorizationHelper.h
//  welike
//
//  Created by fan qi on 2018/6/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^authorizeFinished)(BOOL granted);

@interface WLAuthorizationHelper : NSObject

+ (void)requestPhotoAuthorizationWithFinished:(authorizeFinished)finished;
+ (void)requestCameraAuthorizationWithFinished:(authorizeFinished)finished;
+ (void)requestMicrophoneAuthorizationWithFinished:(authorizeFinished)finished;

@end
