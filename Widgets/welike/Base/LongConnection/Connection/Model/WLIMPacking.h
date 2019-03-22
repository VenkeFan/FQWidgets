//
//  WLIMPacking.h
//  IMTest
//
//  Created by luxing on 2018/5/5.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLIMPacking <NSObject>

@optional
@property (nonatomic, readonly) uint16_t packetType;

@required
- (NSData *)packetBody;

@optional
+ (id<WLIMPacking>)parseFromBody:(NSData *)body;

@end
