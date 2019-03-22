//
//  WLNearbyLocations.h
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import <CoreLocation/CoreLocation.h>


typedef void(^requestSuccessed)(NSArray *locations, NSString *cursor);

@interface WLNearbyLocationsRequest : RDBaseRequest

@property (assign,nonatomic)  CLLocationCoordinate2D currentCoordinate;

- (id)initNearbyLocations:(CLLocationCoordinate2D)coordinate;

- (void)nearbyLocationsWithCursor:(NSString *)cursor successed:(requestSuccessed)successed error:(failedBlock)error;


@end
