//
//  WLIMServerNode.h
//  IMTest
//
//  Created by luxing on 2018/5/4.
//  Copyright © 2018年 chiemy. All rights reserved.
//  

#import <Foundation/Foundation.h>

@interface WLIMServerNode : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;

+ (instancetype)defaultServerNode;

@end
