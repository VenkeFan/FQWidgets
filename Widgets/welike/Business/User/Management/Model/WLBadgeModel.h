//
//  WLBadgeModel.h
//  welike
//
//  Created by fan qi on 2019/2/20.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLBadgeModelType) {
    WLBadgeModelType_Growth         = 1,
    WLBadgeModelType_Activity       = 2,
    WLBadgeModelType_Verified       = 3,
    WLBadgeModelType_Social         = 4
};

@interface WLBadgeModel : NSObject

@property (nonatomic, assign) long long beginTime;
@property (nonatomic, assign) long long endTime;
@property (nonatomic, assign) long long receivedTime;
@property (nonatomic, assign) BOOL expired;
@property (nonatomic, assign) BOOL have;
@property (nonatomic, assign) BOOL weard;
@property (nonatomic, assign) WLBadgeModelType type;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *forwardUrl;
@property (nonatomic, copy) NSString *iconUrl;

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json;

@end
