//
//  WLLocationDetailManager.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationDetailManager.h"
#import "WLLocationPersonsRequest.h"
#import "WLLocationDetailRequest.h"
#import "WLLocationDetail.h"

@implementation WLLocationDetailManager

- (void)loadLocationsDetail:(NSString *)placeId succeed:(locationInfoSuccessed)succeed failed:(locationInfoFailed)failed
{
    WLLocationDetailRequest *request = [[WLLocationDetailRequest alloc] initLocationDetial:placeId];
    [request locationDetial:^(WLLocationDetail *locationInfo) {
         if (succeed) {
               succeed(locationInfo);
         }
    } error:^(NSInteger errorCode) {
        
        if (failed) {
             failed(placeId, errorCode);
        }
    }];
}

-(void)loadLocationDetailUsers:(NSString *)placeId succeed:(listPersonsCompleted)succeed failed:(listPersonsFailed)failed
{
    WLLocationPersonsRequest *locationPersonsRequest = [[WLLocationPersonsRequest alloc] initLocationPersons:placeId];
  
    [locationPersonsRequest locationPersons:0 successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
       
         if ([users count] > 0)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (succeed)
                 {
                     succeed(users, ERROR_SUCCESS);
                 }
             });
         }
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failed)
            {
                failed(nil, errorCode);
            }
        });
        
    }];
}


@end

