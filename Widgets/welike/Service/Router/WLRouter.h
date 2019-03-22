//
//  WLRouter.h
//  welike
//
//  Created by 刘斌 on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLRouterBuilder.h"
#import "WLRouterDefine.h"

@interface WLRouter : NSObject

+ (BOOL)welikeLink:(NSURL *)link;
+ (BOOL)go:(WLRouterBuilder *)builder;

@end
