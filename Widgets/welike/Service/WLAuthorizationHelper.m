//
//  WLAuthorizationHelper.m
//  welike
//
//  Created by fan qi on 2018/6/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAuthorizationHelper.h"
#import "WLAlertController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, WLAuthorizationType) {
    WLAuthorizationType_Photo,
    WLAuthorizationType_Camera,
    WLAuthorizationType_Microphone,
    WLAuthorizationType_Location
};

@implementation WLAuthorizationHelper

#pragma mark - Public

+ (void)requestPhotoAuthorizationWithFinished:(authorizeFinished)finished {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                BOOL granted = (status == PHAuthorizationStatusAuthorized);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finished) {
                        finished(granted);
                    }
                });
            }];
        } else if (authStatus == PHAuthorizationStatusAuthorized) {
            if (finished) {
                finished(YES);
            }
        } else {
            [self p_showMessageWithType:WLAuthorizationType_Photo finished:finished];
        }
    }
}

+ (void)requestCameraAuthorizationWithFinished:(authorizeFinished)finished {
    AVMediaType mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType
                                 completionHandler:^(BOOL granted) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (finished) {
                                             finished(granted);
                                         }
                                     });
                                 }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        if (finished) {
            finished(YES);
        }
    } else {
        [self p_showMessageWithType:WLAuthorizationType_Camera finished:finished];
    }
}

+ (void)requestMicrophoneAuthorizationWithFinished:(authorizeFinished)finished {
    AVMediaType mediaType = AVMediaTypeAudio;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType
                                 completionHandler:^(BOOL granted) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (finished) {
                                             finished(granted);
                                         }
                                     });
                                 }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        if (finished) {
            finished(YES);
        }
    } else {
        [self p_showMessageWithType:WLAuthorizationType_Microphone finished:finished];
    }
}

#pragma mark - Private

+ (void)p_showMessageWithType:(WLAuthorizationType)type finished:(authorizeFinished)finished {
    NSString *str = nil;
    
    switch (type) {
        case WLAuthorizationType_Photo:
            str = [AppContext getStringForKey:@"authorize_photo" fileName:@"common"];
            break;
        case WLAuthorizationType_Camera:
            str = [AppContext getStringForKey:@"authorize_camera" fileName:@"common"];
            break;
        case WLAuthorizationType_Microphone:
            str = [AppContext getStringForKey:@"authorize_microphone" fileName:@"common"];
            break;
        case WLAuthorizationType_Location:
            str = [AppContext getStringForKey:@"authorize_location" fileName:@"common"];
            break;
    }
    
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil
                                                                   message:str
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"mine_setting_text" fileName:@"user"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                
                                                if (@available(iOS 10.0, *)) {
                                                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                } else {
                                                    [[UIApplication sharedApplication] openURL:url];
                                                }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                if (finished) {
                                                    finished(NO);
                                                }
                                            }]];
    
    [[AppContext currentViewController] presentViewController:alert animated:YES completion:nil];
}

@end
