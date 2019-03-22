//
//  WLTrackerActivity.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerActivity.h"
#import "WLAbstractCameraViewController.h"

#define kWLTrackerActivityEventIDKey                  @"5001024"

NSDictionary * activityDicFun() {
    static NSDictionary *activityDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activityDic = @{@"WLDiscoveryViewController": @"discover_tab",
                        @"WLMessageViewController": @"message_tab",
                        @"WLMeViewController": @"me_tab",
                        @"WLPostViewController": @"publish_post",
                        @"WLHomeViewController": @"home",
                        @"WLContactListViewController": @"search_buddy",
                        @"WLAssetsViewController": @"pick_image",
                        @"WLImageBrowseView": @"preview_feed_image",
                        @"WLAssetsBrowseViewController": @"preview_image",
                        @"WLSplashViewController": @"entrance",
                        @"WLPlayerViewController": @"video_player",
                        @"WLRegisterSMSCodeViewController": @"register_and_login",
                        @"WLSearchLocationViewController": @"pick_location",
                        @"WLShareViewController": @"share",
                        @"WLCutImageViewController": @"crop_image",
                        @"WLSearchPersonResultOnlineController": @"search_buddy_online",
                        @"WLWebViewController": @"webview",
                        @"WLAbstractCameraViewController_1": @"video_recorder",
                        @"WLAbstractCameraViewController_0": @"photo_snap_shot",
                        @"WLPlayerViewController": @"youtube_player",
                        //                          @"": @"scheme_filter",
                        @"WLMainViewController": @"main_page",
                        @"WLTopicDetailViewController": @"topic_landing",
                        @"WLTopicUsersViewController": @"topic_user",
                        //                        @"": @"topic_list",
                        @"WLRegisterInterestsViewController": @"choice_interest",
                        //                          @"": @"deactivate_account_confirm",
                        //                          @"": @"deactivate_account_reason",
                        //                          @"": @"deactivate_account_callback",
                        @"WLCommentDetailViewController": @"comment_detail",
                        @"WLFeedDetailViewController": @"feed_detail",
                        @"WLGuideViewController": @"login_dialog",
                        @"WLRegisterSelectLanguageViewController": @"language_choose_dialog",
                        //                          @"": @"publish_article",
                        //                          @"": @"publish_article_preview",
                        @"WLCommentPostViewController": @"publish_comment",
                        @"WLRepostViewController": @"publish_repost",
                        //                          @"": @"publish_reply",
                        @"WLPostStatusViewController": @"post_status",
                        @"WLContactListViewController": @"contact_list",
                        //                          @"": @"user_edit_interest",
                        //                          @"": @"recommend_follow",
                        @"WLDraftViewController": @"draft",
                        @"WLTopicSearchViewController": @"topic_choice",
                        //                          @"": @"deactivate_account_result",
                        //                          @"": @"restore_account",
                        @"WLUserDetailViewController": @"profile",
                        @"WLFollowViewController": @"user_follow",
                        @"WLBlockUsersListViewController": @"block_user",
                        //                          @"": @"block_following",
                        //                          @"": @"block_search",
                        @"WLPersonalEditViewController": @"personal_information",
                        //                          @"": @"user_interest_select",
                        @"WLModifyGenderViewController": @"edit_sex",
                        @"WLModifyIntroViewController": @"edit_brief",
                        @"WLModifyNickNameViewController": @"edit_name",
                        @"WLSettingViewController": @"setting",
                        @"WLLanguageSwitchViewController": @"setting_language",
                        //                          @"": @"setting_privacy",
                        @"WLReportViewController": @"report",
                        @"WLPrivateMessageViewController": @"chat",
                        @"WLChatListViewController": @"stranger_session",
                        @"WLPrivateMessageViewController": @"route_chat",
                        //                          @"": @"mylike",
                        //                          @"": @"social_host_input",
                        //                          @"": @"h5",
                        //                          @"": @"report_description",
                        @"WLUnloginHomeViewController": @"no_login_main",
                        //                          @"": @"latest_campaign",
                        @"WLPlayerCollectionView": @"video_player_apollo",
                        //                          @"": @"profile_photo_detail",
                        //                          @"": @"contact",
                        @"WLMsgBoxViewController": @"message_box",
                        @"WLNotificationSettingViewController": @"notification",
                        @"WLLocationDetailViewController": @"lbs",
                        @"WLLocationsUserlistViewController": @"lbs_passerby",
                        //                          @"": @"quite_time",
                        @"WLSearchResultViewController": @"search_result",
                        //                          @"": @"article_detail",
                        //                          @"": @"super_topic_landing",
                        //                          @"": @"super_topic_chosen",
                        //                          @"": @"QR_code_share"
                        };
    });
    
    return activityDic;
}

NSString *activityNameWithClass(Class cls) {
    NSDictionary *activityDic = activityDicFun();
    
    NSString *className = NSStringFromClass(cls);
    NSString *name = [activityDic objectForKey:className];
    
    return name;
}

NSString *activityNameWithObject(NSObject *obj) {
    NSDictionary *activityDic = activityDicFun();
    
    NSString *className = NSStringFromClass([obj class]);
    if ([obj isKindOfClass:[WLAbstractCameraViewController class]]) {
        WLAbstractCameraViewController *ctr = (WLAbstractCameraViewController *)obj;
        className = [className stringByAppendingString:[NSString stringWithFormat:@"_%d", (int)ctr.outputType]];
        
        NSString *name = [activityDic objectForKey:className];
        return name;
    } else {
        return activityNameWithClass([obj class]);
    }
}

@implementation WLTrackerActivity

+ (void)appendTrackerWithActivityType:(WLTrackerActivityType)type
                                  cls:(Class)cls
                             duration:(NSTimeInterval)duration {
    NSString *name = activityNameWithClass(cls);
    
    if (name.length == 0) {
        name = NSStringFromClass(cls);
#ifdef __WELIKE_TEST_
        NSLog(@"=========> WLTrackerActivity Class Name: %@", name);
#endif
    }
    
    [self appendTrackerWithActivityType:type
                                clsName:name
                               duration:duration];
}

+ (void)appendTrackerWithActivityType:(WLTrackerActivityType)type
                                  obj:(NSObject *)obj
                             duration:(NSTimeInterval)duration {
    NSString *name = activityNameWithObject(obj);
    
    if (name.length == 0) {
        name = NSStringFromClass([obj class]);
#ifdef __WELIKE_TEST_
        NSLog(@"=========> WLTrackerActivity Class Name: %@", name);
#endif
    }
    
    [self appendTrackerWithActivityType:type
                                clsName:name
                               duration:duration];
}

+ (void)appendTrackerWithActivityType:(WLTrackerActivityType)type
                              clsName:(NSString *)clsName
                             duration:(NSTimeInterval)duration {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(type) forKey:@"action"];
    
    if (clsName) {
        [eventInfo setObject:clsName forKey:@"activityname"];
    }
    
    if (type == WLTrackerActivityType_Transition) {
        [eventInfo setObject:@(duration) forKey:@"staytime"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerActivityEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
