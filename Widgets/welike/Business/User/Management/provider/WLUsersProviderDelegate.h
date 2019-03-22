//
//  WLUsersProviderDelegate.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLUsersProvider;

@protocol WLUsersProviderDelegate <NSObject>

- (void)onRefreshUsersProvider:(id<WLUsersProvider>)provider users:(NSArray *)users kid:(NSString *)kid newCount:(NSInteger)newCount last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveHisUsersProvider:(id<WLUsersProvider>)provider users:(NSArray *)users kid:(NSString *)kid last:(BOOL)last errCode:(NSInteger)errCode;

@end
