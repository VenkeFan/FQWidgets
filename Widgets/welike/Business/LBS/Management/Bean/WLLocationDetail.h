//
//  WLLocationDetail.h
//  welike
//
//  Created by gyb on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLLocationDetail : NSObject


@property (strong,nonatomic)  NSString  *placeName;
@property (strong,nonatomic)  NSString  *photo;
@property (assign,nonatomic)  NSInteger  feedCount;
@property (assign,nonatomic)  NSInteger  userCount;

+ (WLLocationDetail *)parseFromNetworkJSON:(NSDictionary *)json;

@end
