//
//  WLStatusTrack.m
//  welike
//
//  Created by gyb on 2018/12/21.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLStatusTrack.h"
#import "WLTracker.h"


#define kWLTrackStatusEventID                    @"5001006"

@implementation WLStatusTrack

+(void)mainBtnInTabBarHasAnimation
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(1) forKey:@"action"];
 
    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+(void)postStatusAppear:(WLStatusTrack_from)satusTrack_from
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(2) forKey:@"action"];
    [eventInfo setObject:@(satusTrack_from) forKey:@"from"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+(void)postStatusHasEdited:(WLStatusTrack_buttontype)statusTrack_buttontype
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(3) forKey:@"action"];
    [eventInfo setObject:@(statusTrack_buttontype) forKey:@"buttontype"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+(void)postStatusSendPressed:(BOOL)textchanged
                     content:(NSString *)textStr
                     imageId:(NSString *)imageId
                  categoryID:(NSString *)categoryID
                categoryName:(NSString *)categoryName
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(4) forKey:@"action"];
    [eventInfo setObject:@(textchanged) forKey:@"textchanged"];
     [eventInfo setObject:textStr forKey:@"text"];
     [eventInfo setObject:imageId forKey:@"imageid"];
     [eventInfo setObject:categoryID forKey:@"categoryID"];
     [eventInfo setObject:categoryName forKey:@"categoryName"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+(void)clickDownloadPic
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(5) forKey:@"action"];
  
    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+(void)selectPic
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(6) forKey:@"action"];

    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+(void)clickEmoji
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(7) forKey:@"action"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackStatusEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
