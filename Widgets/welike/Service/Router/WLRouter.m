//
//  WLRouter.m
//  welike
//
//  Created by 刘斌 on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRouter.h"
#import "WLAccountManager.h"
#import "WLMainViewController.h"
#import "WLPostViewController.h"
#import "WLPersonalEditViewController.h"
#import "WLWebViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLUserDetailViewController.h"
#import "WLLocationDetailViewController.h"
#import "WLShareViewController.h"
#import "NSDictionary+JSON.h"

@implementation WLRouter

+ (BOOL)welikeLink:(NSURL *)link
{
    if ([link.scheme isEqualToString:@"welike"] == NO) return NO;
    if ([link.host isEqualToString:@"com.redefine.welike"] == NO) return NO;
    
    return YES;
}

+ (BOOL)go:(WLRouterBuilder *)builder
{
    if (builder == nil) return NO;
    
    if (builder.type == WELIKE_ROUTER_TYPE_NAV)
    {
        if (builder.group == nil || [builder.group length] == 0) return NO;
        if (builder.mainTab == nil || [builder.mainTab length] == 0) return NO;
        
        if ([builder.group isEqualToString:WLROUTER_GROUP_MAIN] == YES)
        {
            return [WLRouter goMain:builder];
        }
    }
    else if (builder.type == WELIKE_ROUTER_TYPE_WEB)
    {
        return [WLRouter goWeb:builder];
    }
    
    return NO;
}

+ (BOOL)goWeb:(WLRouterBuilder *)builder
{
    if ([builder.web length] > 0)
    {
        WLWebViewController *vc = [[WLWebViewController alloc] initWithUrl:builder.web];
        [[AppContext rootViewController] pushViewController:vc animated:YES];
        return YES;
    }
    return NO;
}

+ (BOOL)goMain:(WLRouterBuilder *)builder
{
//    NSArray *controllers = [[AppContext rootViewController] viewControllers];
    
//    if ([controllers.firstObject isKindOfClass:[WLMainViewController class]] == NO)
//
//        return NO;
    
    if ([builder.mainTab isEqualToString:WLROUTER_MAINTAB_HOME] == YES)
    {
        if (builder.pageName == nil || [builder.pageName length] == 0)
        {
            [AppContext mainViewController].selectedIndex = 0;
        }
    }
    else if ([builder.mainTab isEqualToString:WLROUTER_MAINTAB_DISCOVERY] == YES)
    {
        if (builder.pageName == nil || [builder.pageName length] == 0)
        {
            [AppContext mainViewController].selectedIndex = 1;
        }
    }
    else if ([builder.mainTab isEqualToString:WLROUTER_MAINTAB_MESSAGE] == YES)
    {
        if (builder.pageName == nil || [builder.pageName length] == 0)
        {
            [AppContext mainViewController].selectedIndex = 2;
        }
    }
    else if ([builder.mainTab isEqualToString:WLROUTER_MAINTAB_ME] == YES)
    {
        if (builder.pageName == nil || [builder.pageName length] == 0)
        {
            [AppContext mainViewController].selectedIndex = 3;
        }
    }
    else
    {
        return NO;
    }
    
    if ([builder.pageName length] > 0)
    {
        if ([builder.pageName isEqualToString:WLROUTER_PAGE_HOME] == YES)
        {
            [AppContext mainViewController].selectedIndex = 0;
        }
        else if ([builder.pageName isEqualToString:WLROUTER_PAGE_DISCOVERY] == YES)
        {
            [AppContext mainViewController].selectedIndex = 1;
        }
        else if ([builder.pageName isEqualToString:WLROUTER_PAGE_MESSAGE] == YES)
        {
            [AppContext mainViewController].selectedIndex = 2;
        }
        else if ([builder.pageName isEqualToString:WLROUTER_PAGE_ME] == YES)
        {
            [AppContext mainViewController].selectedIndex = 3;
        }
        else
        {
            NSInteger popToRoot = [builder.params integerForKey:WLROUTER_PARAM_POP_TO_ROOT def:0];
            if (popToRoot != 0)
            {
                [[AppContext rootViewController] popToViewController:[AppContext mainViewController] animated:NO];
            }
            
            RDBaseViewController *vc = nil;
            if ([builder.pageName isEqualToString:WLROUTER_PAGE_PUBLISH] == YES)
            {
                vc = [[WLPostViewController alloc] init];
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_EDIT_USER_INFO] == YES)
            {
                vc = [[WLPersonalEditViewController alloc] init];
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_SHARE] == YES)
            {
                NSInteger from = [builder.params integerForKey:WLROUTER_PARAM_SHARE_FROM def:0];
                NSString *objId = [builder.params stringForKey:WLROUTER_PARAM_SHARE_POST_ID];
                NSString *nickName = [builder.params stringForKey:WLROUTER_PARAM_SHARE_NICK_NAME];
                NSString *imageUrl = [builder.params stringForKey:WLROUTER_PARAM_SHARE_IMAGE];
                WLShareViewController *svc = nil;
                if (from == 1)
                {
                    svc = [[WLShareViewController alloc] init];
                    svc.shareModel = [WLShareModel modelWithID:objId type:WLShareModelType_Feed title:nickName desc:nil imgUrl:imageUrl linkUrl:nil];
                }
                else if (from == 2)
                {
                    svc = [[WLShareViewController alloc] init];
                    svc.shareModel = [WLShareModel modelWithID:objId type:WLShareModelType_App title:nickName desc:nil imgUrl:imageUrl linkUrl:nil];
                }
                else if (from == 3)
                {
                    svc = [[WLShareViewController alloc] init];
                    svc.shareModel = [WLShareModel modelWithID:objId type:WLShareModelType_App title:nickName desc:nil imgUrl:imageUrl linkUrl:nil];
                }
                else if (from == 4)
                {
                    svc = [[WLShareViewController alloc] init];
                    svc.shareModel = [WLShareModel modelWithID:objId type:WLShareModelType_Profile title:nickName desc:nil imgUrl:imageUrl linkUrl:nil];
                }
                else if (from == 5)
                {
                    svc = [[WLShareViewController alloc] init];
                    svc.shareModel = [WLShareModel modelWithID:objId type:WLShareModelType_Topic title:nickName desc:nil imgUrl:imageUrl linkUrl:nil];
                }
                vc = svc;
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_WEBVIEW] == YES)
            {
                NSString *url = [builder.params stringForKey:WLROUTER_PARAM_WEBVIEW_URL];
                if ([url length] > 0)
                {
                    vc = [[WLWebViewController alloc] initWithUrl:url];
                }
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_POST_DETAIL] == YES)
            {
                NSString *pid = [builder.params stringForKey:WLROUTER_PARAM_POST_PID];
                if ([pid length] > 0)
                {
                    vc = [[WLFeedDetailViewController alloc] initWithID:pid];
                }
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_TOPIC_LANDING] == YES)
            {
                NSString *topicId = [builder.params stringForKey:WLROUTER_PARAM_TOPIC_LANDING_TOPIC_ID];
                if ([topicId length] > 0)
                {
                    vc = [[WLTopicDetailViewController alloc] initWithTopicID:topicId];
                }
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_LBS_LANDING] == YES)
            {
                vc = [[WLLocationDetailViewController alloc] init];
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_USER_PROFILE] == YES)
            {
                NSString *uid = [builder.params stringForKey:WLROUTER_PARAM_PROFILE_UID];
                if ([uid length] > 0)
                {
                    vc = [[WLUserDetailViewController alloc] initWithUserID:uid];
                }
            }
            else if ([builder.pageName isEqualToString:WLROUTER_PAGE_MY_PROFILE] == YES)
            {
                vc = [[WLUserDetailViewController alloc] initWithUserID:[[AppContext getInstance].accountManager myAccount].uid];
            }
            if (vc != nil)
            {
                if ([builder.params count] > 0)
                {
                    vc.routerParams = [NSDictionary dictionaryWithDictionary:builder.params];
                }
                if ([vc isKindOfClass:[WLPostViewController class]] == YES)
                {
                    WLPostViewController *postViewController = (WLPostViewController *)vc;
                    postViewController.title = [AppContext getStringForKey:@"editor_post_title" fileName:@"publish"];
                    RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:postViewController];
                    [[AppContext currentViewController] presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
                else if ([vc isKindOfClass:[WLShareViewController class]] == YES)
                {
                    [[AppContext currentViewController] presentViewController:vc animated:YES completion:^{
                        
                    }];
                }
                else
                {
                    [[AppContext rootViewController] pushViewController:vc animated:YES];
                }
            }
        }
    }
    
    return YES;
}

@end
