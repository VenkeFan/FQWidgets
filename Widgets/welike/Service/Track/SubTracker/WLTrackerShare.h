//
//  WLTrackerShare.h
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLShareModel;

typedef NS_ENUM(NSInteger, WLTrackerShareAction) {
    WLTrackerShareAction_Share      = 1,
    WLTrackerShareAction_QRCode,
    WLTrackerShareAction_Done
};

typedef NS_ENUM(NSInteger, WLTrackerShareFrom) {
    WLTrackerShareFrom_Cell             = 1,
    WLTrackerShareFrom_Player           = 2,
    WLTrackerShareFrom_PostDetail       = 3,
    WLTrackerShareFrom_OtherPage        = 4,
    WLTrackerShareFrom_Article          = 5,
    WLTrackerShareFrom_PhotoAlbum       = 6,
    WLTrackerShareFrom_ScreenShot       = 7,
    WLTrackerShareFrom_PublishPost      = 8
};

typedef NS_ENUM(NSInteger, WLTrackerShareChannel) {
    WLTrackerShareChannel_WhatsApp          = 1,
    WLTrackerShareChannel_Facebook          = 2,
    WLTrackerShareChannel_Instagram         = 3,
    WLTrackerShareChannel_Copy              = 4,
    WLTrackerShareChannel_Other             = 5,
    WLTrackerShareChannel_QRCode            = 6
};

typedef NS_ENUM(NSInteger, WLTrackerShareContentType) {
    WLTrackerShareContentType_Post          = 1,
    WLTrackerShareContentType_App           = 2,
    WLTrackerShareContentType_Profile       = 4,
    WLTrackerShareContentType_Topic         = 5,
    WLTrackerShareContentType_WebView       = 7
};

typedef NS_ENUM(NSInteger, WLTrackerShareResult) {
    WLTrackerShareResult_Failed             = 0,
    WLTrackerShareResult_Succeed            = 1,
    WLTrackerShareResult_Unknow             = 2
};

typedef NS_ENUM(NSInteger, WLTrackerShareVideoType) {
    WLTrackerShareVideoType_Video           = 1,
    WLTrackerShareVideoType_Link            = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerShare : NSObject

+ (void)appendTrackerWithShareModel:(WLShareModel *)shareModel
                            channel:(WLTrackerShareChannel)channel
                             result:(WLTrackerShareResult)result;

+ (void)appendTrackerWithShareModel:(WLShareModel *)shareModel
                               from:(WLTrackerShareFrom)from
                            channel:(WLTrackerShareChannel)channel
                             result:(WLTrackerShareResult)result;

@end

NS_ASSUME_NONNULL_END
