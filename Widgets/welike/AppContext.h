//
//  AppContext.h
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDRootViewController;
@class WLMainViewController;
@class RDBaseViewController;
@class WLAccountManager;
@class WLStartHandler;
@class WLUploadManager;
@class WLContactsManager;
@class WLDraftManager;
@class WLPublishTaskManager;
@class WLSingleContentManager;
@class WLSingleUserManager;
@class WLMessageCountObserver;
@class WLPushSettingManager;

@interface AppContext : NSObject

@property (nonatomic, readonly) WLAccountManager *accountManager;
@property (nonatomic, readonly) WLStartHandler *startHandler;
@property (nonatomic, readonly) WLUploadManager *uploadManager;
@property (nonatomic, readonly) WLContactsManager *contactsManager;
@property (nonatomic, readonly) WLDraftManager *draftManager;
@property (nonatomic, readonly) WLPublishTaskManager *publishTaskManager;
@property (nonatomic, readonly) WLSingleContentManager *singleContentManager;
@property (nonatomic, readonly) WLSingleUserManager *singleUserManager;
@property (nonatomic, readonly) WLMessageCountObserver *messageCountObserver;
@property (nonatomic, readonly) WLPushSettingManager *pushSettingManager;

+ (AppContext *)getInstance;
+ (RDRootViewController *)rootViewController;
+ (WLMainViewController *)mainViewController;
+ (RDBaseViewController *)currentViewController;
+ (UIImage *)getImageForKey:(NSString *)key;
+ (NSString *)getStringForKey:(NSString *)key fileName:(NSString *)fileName;
+ (NSString *)getCachePath;
+ (NSString *)getHostName;
+ (NSString *)getUploadHostName;
+ (NSString *)getDownloadHostName;
+ (NSString *)getTrackHostName;
+ (NSString *)getLongConnectionHostName;
+ (NSInteger)getLongConnectionPort;
+ (void)logout;
- (void)testEnvSwitch:(NSString *)env;

//new upload
+ (NSString *)getAliBucket;
+ (NSString *)getEndPoint;
+ (NSString *)getAliUploadHostName;
+ (NSString *)getSts;


@end
