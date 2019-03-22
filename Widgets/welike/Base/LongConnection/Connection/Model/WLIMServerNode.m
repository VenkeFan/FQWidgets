//
//  WLIMServerNode.m
//  IMTest
//
//  Created by luxing on 2018/5/4.
//  Copyright © 2018年 chiemy. All rights reserved.
//  场链接时候的ip和port,目前是固定值

#import "WLIMServerNode.h"

@implementation WLIMServerNode

+ (instancetype)defaultServerNode
{
    WLIMServerNode *node = [[self alloc] init];
    node.host = [AppContext getLongConnectionHostName];
    node.port = [AppContext getLongConnectionPort];
    return node;
}

@end
