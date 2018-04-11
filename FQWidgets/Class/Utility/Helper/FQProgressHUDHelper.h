//
//  FQProgressHUDHelper.h
//  WeLike
//
//  Created by fan qi on 2018/4/10.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQProgressHUDHelper : NSObject

+ (void)showWithMessage:(NSString *)message;
+ (void)showErrorWithMessage:(NSString *)message;

@end
