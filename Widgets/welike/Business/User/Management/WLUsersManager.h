//
//  WLUsersManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLUsersProvider.h"
#import "WLUsersProviderDelegate.h"

@class WLUsersManager;

typedef void(^pinCompleted) (BOOL isSuccess, NSInteger errCode);

@protocol WLUsersManagerDelegate <NSObject>

- (void)onRefreshManager:(WLUsersManager *)manager users:(NSArray *)users kid:(NSString *)kid newCount:(NSInteger)newCount last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveHisManager:(WLUsersManager *)manager users:(NSArray *)users kid:(NSString *)kid last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLUsersManager : NSObject

@property (nonatomic, weak) id<WLUsersManagerDelegate> delegate;

- (void)setDataSourceProvider:(id<WLUsersProvider>)provider;
- (void)tryRefreshUsersWithKeyId:(NSString *)kid;
- (void)tryHisUsersWithKeyId:(NSString *)kid;

- (void)removeRecommendUser:(NSString *)userID;

-(void)pinPost:(NSString *)pid complete:(pinCompleted)complete;
-(void)unPinPost:(NSString *)pid complete:(pinCompleted)complete;

@end
