//
//  WLSearchLocationRequest.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import <CoreLocation/CoreLocation.h>

typedef void(^requestSuccessed)(NSArray *locations, NSString *cursor);

@interface WLSearchLocationRequest : RDBaseRequest

@property (assign,nonatomic)  CLLocationCoordinate2D currentCoordinate;

@property (copy,nonatomic)  NSString *key;


- (id)initSearchLocations:(CLLocationCoordinate2D)coordinate keyStr:(NSString *)keyStr;

- (void)SearchLocationsWithCursor:(NSString *)cursor successed:(requestSuccessed)successed error:(failedBlock)error;



@end
