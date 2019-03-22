//
//  WLTrackUseTime.m
//  welike
//
//  Created by gyb on 2018/12/24.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackUseTime.h"
#import "WLTracker.h"

@implementation WLTrackUseTime

+(void)trackUseTimeLength:(NSTimeInterval)timeLength
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(timeLength) forKey:@"stay_time"];
    
    [[WLTracker getInstance] appendEventId:@"5001089"
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}




@end
