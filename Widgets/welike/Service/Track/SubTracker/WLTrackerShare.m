//
//  WLTrackerShare.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerShare.h"
#import "WLTracker.h"
#import "WLShareModel.h"

#define kWLTrackerShareEventIDKey                  @"5001004"

typedef NS_ENUM(NSInteger, WLTrackerSharePopPageFrom) {
    WLTrackerSharePopPageFrom_PostDetail    = 1,
    WLTrackerSharePopPageFrom_Cell          = 2,
    WLTrackerSharePopPageFrom_Profile       = 3,
    WLTrackerSharePopPageFrom_ShareApp      = 4,
    WLTrackerSharePopPageFrom_Topic         = 5,
    WLTrackerSharePopPageFrom_WebView       = 6
};

@implementation WLTrackerShare

+ (void)appendTrackerWithShareModel:(WLShareModel *)shareModel
                            channel:(WLTrackerShareChannel)channel
                             result:(WLTrackerShareResult)result {
    WLTrackerShareFrom from = [self shareFrom:shareModel];
    
    [self appendTrackerWithShareModel:shareModel
                                 from:from
                              channel:channel
                               result:result];
}

+ (void)appendTrackerWithShareModel:(WLShareModel *)shareModel
                               from:(WLTrackerShareFrom)from
                            channel:(WLTrackerShareChannel)channel
                             result:(WLTrackerShareResult)result {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerShareAction_Share) forKey:@"action"];
    [eventInfo setObject:@(channel) forKey:@"share_channel"];
    [eventInfo setObject:@([self shareContentType:shareModel]) forKey:@"content_type"];
    [eventInfo setObject:@(from) forKey:@"share_from"];
    [eventInfo setObject:@([self popPageFrom:shareModel]) forKey:@"pop_page"];
    [eventInfo setObject:@([AppContext getInstance].accountManager.isLogin) forKey:@"is_login"];
    [eventInfo setObject:@(result) forKey:@"is_success"];
    
    if (shareModel.postModel) {
        [eventInfo setObject:@(trackerPostType(shareModel.postModel)) forKey:@"post_type"];
        
        if (shareModel.postModel.type == WELIKE_POST_TYPE_VIDEO) {
            [eventInfo setObject:@(WLTrackerShareVideoType_Video) forKey:@"videopost_type"];
        }
        
        if (shareModel.postModel.pid) {
            [eventInfo setObject:shareModel.postModel.pid forKey:@"post_id"];
        }
        
        NSString *source = trackerFeedSource(shareModel.postModel.trackerSource, shareModel.postModel.trackerSubType);
        if (source) {
            [eventInfo setObject:source forKey:@"source"];
        }
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerShareEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (WLTrackerShareContentType)shareContentType:(WLShareModel *)shareModel {
    WLTrackerShareContentType contentType = WLTrackerShareContentType_Post;
    
    switch (shareModel.type) {
        case WLShareModelType_Feed:
            contentType = WLTrackerShareContentType_Post;
            break;
        case WLShareModelType_App:
            contentType = WLTrackerShareContentType_App;
            break;
        case WLShareModelType_Profile:
            contentType = WLTrackerShareContentType_Profile;
            break;
        case WLShareModelType_Topic:
            contentType = WLTrackerShareContentType_Topic;
            break;
        case WLShareModelType_WebView:
            contentType = WLTrackerShareContentType_WebView;
            break;
        default:
            contentType = WLTrackerShareContentType_Post;
            break;
    }
    
    return contentType;
}

+ (WLTrackerShareFrom)shareFrom:(WLShareModel *)shareModel {
    WLTrackerShareFrom from = WLTrackerShareFrom_OtherPage;
    
    if ([shareModel.postModel.trackerSubType isEqualToString:kWLTrackerFeedSubType_VideoSimilar]) {
        from = WLTrackerShareFrom_Player;
    }
    
    return from;
}

+ (WLTrackerSharePopPageFrom)popPageFrom:(WLShareModel *)shareModel {
    WLTrackerSharePopPageFrom popFrom = WLTrackerSharePopPageFrom_Cell;
    
    switch (shareModel.type) {
        case WLShareModelType_Feed: {
            if (shareModel.postModel.trackerSource == WLTrackerFeedSource_FeedDetail
                || shareModel.postModel.trackerSource == WLTrackerFeedSource_FeedDetail_Bottom) {
                popFrom = WLTrackerSharePopPageFrom_PostDetail;
            } else {
                popFrom = WLTrackerSharePopPageFrom_Cell;
            }
        }
            break;
        case WLShareModelType_App:
            popFrom = WLTrackerSharePopPageFrom_ShareApp;
            break;
        case WLShareModelType_Profile:
            popFrom = WLTrackerSharePopPageFrom_Profile;
            break;
        case WLShareModelType_Topic:
            popFrom = WLTrackerSharePopPageFrom_Topic;
            break;
        case WLShareModelType_WebView:
            popFrom = WLTrackerSharePopPageFrom_WebView;
            break;
        default:
            break;
    }
    
    return popFrom;
}

@end
