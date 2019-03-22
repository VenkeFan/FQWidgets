//
//  WLLocationRequest.h
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^listLocationsCompleted) (NSArray *locations, BOOL last, NSInteger errCode);

@interface WLLocationManager : NSObject



-(void)listNearbyLocations:(CLLocationCoordinate2D)coordinate result:(listLocationsCompleted)complete;

-(void)listNearbyLocationsFromBottom:(CLLocationCoordinate2D)coordinate result:(listLocationsCompleted)complete;


-(void)listSearchLocations:(CLLocationCoordinate2D)coordinate key:(NSString *)key result:(listLocationsCompleted)complete;
-(void)listSearchLocationsFromBottom:(CLLocationCoordinate2D)coordinate key:(NSString *)key result:(listLocationsCompleted)complete;



@end
