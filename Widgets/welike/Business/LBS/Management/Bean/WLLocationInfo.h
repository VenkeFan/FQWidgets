//
//  WLLocationInfo.h
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLLocationInfo : NSObject

@property (strong,nonatomic)  NSString  *placeId;
@property (strong,nonatomic)  NSString  *name;
@property (strong,nonatomic)  NSString  *photo;
@property (assign,nonatomic)  CGFloat   lat;
@property (assign,nonatomic)  CGFloat   lng;
@property (assign,nonatomic)  NSInteger  feedCount;
@property (assign,nonatomic)  NSInteger  userCount;



+ (WLLocationInfo *)parseFromNetworkJSON:(NSDictionary *)json;

@end
