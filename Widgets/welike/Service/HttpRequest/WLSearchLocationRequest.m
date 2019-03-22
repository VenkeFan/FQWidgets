//
//  WLSearchLocationRequest.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchLocationRequest.h"
#import "WLLocationInfo.h"

@implementation WLSearchLocationRequest

- (id)initSearchLocations:(CLLocationCoordinate2D)coordinate keyStr:(NSString *)keyStr
{
    _currentCoordinate = coordinate;
    _key = keyStr;
    return [super initWithType:AFHttpOperationTypeNormal api:@"lbs/search" method:AFHttpOperationMethodGET];
}

- (void)SearchLocationsWithCursor:(NSString *)cursor successed:(requestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithFloat:_currentCoordinate.longitude] forKey:@"lng"];
    [self.params setObject:[NSNumber numberWithFloat:_currentCoordinate.latitude] forKey:@"lat"];
    [self.params setObject:_key forKey:@"keyword"];
    
    
    if (cursor.length > 0)
    {
        [self.params setObject:cursor forKey:@"pageToken"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSString *cursor = [resDic stringForKey:@"pageToken"];
            
            NSMutableArray *places = nil;
            NSArray *placesJSON = [resDic objectForKey:@"places"];
            if ([placesJSON count] > 0)
            {
                places = [NSMutableArray arrayWithCapacity:[placesJSON count]];
                for (NSInteger i = 0; i < [placesJSON count]; i++)
                {
                    WLLocationInfo *info = [WLLocationInfo parseFromNetworkJSON:[placesJSON objectAtIndex:i]];
                    if (info != nil)
                    {
                        [places addObject:info];
                    }
                }
            }
            
            if (successed)
            {
                successed(places, cursor);
            }
        }
        else
        {
            if (error)
            {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end