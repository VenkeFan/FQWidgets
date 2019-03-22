//
//  WLTrackerProfile.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerProfile.h"
#import "WLTracker.h"

#define kWLTrackerProfileEventIDKey                  @"5001015"

@implementation WLTrackerProfile

+ (void)appendTrackerWithProfileAction:(WLTrackerProfileActionType)action
                            pageSource:(WLTrackerProfileSource)pageSource
                              moreType:(WLTrackerProfileMoreType)moreType
                                userID:(NSString *)userID {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(action) forKey:@"action"];
    
    BOOL isMyself = [userID isEqualToString:[AppContext getInstance].accountManager.myAccount.uid];
    WLTrackerProfileUserType userType = isMyself ? WLTrackerProfileUserType_Master: WLTrackerProfileUserType_Visitor;
    
    switch (action) {
        case WLTrackerProfileActionType_Display: {
            [eventInfo setObject:@(pageSource) forKey:@"from_page"];
            [eventInfo setObject:@(userType) forKey:@"user_type"];
        }
            break;
        case WLTrackerProfileActionType_Icon: {
            
        }
            break;
        case WLTrackerProfileActionType_More: {
            [eventInfo setObject:@(moreType) forKey:@"more_type"];
        }
            break;
        case WLTrackerProfileActionType_SnakeDisplay:
        case WLTrackerProfileActionType_SnakeApply: {
            
        }
            break;
        case WLTrackerProfileActionType_Likes: {
            [eventInfo setObject:@(userType) forKey:@"user_type"];
        }
            break;
        default:
            break;
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerProfileEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
