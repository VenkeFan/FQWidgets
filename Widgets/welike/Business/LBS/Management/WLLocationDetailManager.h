//
//  WLLocationDetailManager.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLLocationDetail;
typedef void(^locationInfoSuccessed)(WLLocationDetail *locationInfo);
typedef void(^locationInfoFailed)(NSString *placeId, NSInteger errorCode);

typedef void(^listPersonsCompleted) (NSArray *users, NSInteger errCode);
typedef void(^listPersonsFailed) (NSArray *users, NSInteger errCode);

@interface WLLocationDetailManager : NSObject

- (void)loadLocationsDetail:(NSString *)placeId succeed:(locationInfoSuccessed)succeed failed:(locationInfoFailed)failed;

-(void)loadLocationDetailUsers:(NSString *)placeId succeed:(listPersonsCompleted)succeed failed:(listPersonsFailed)failed;


@end
