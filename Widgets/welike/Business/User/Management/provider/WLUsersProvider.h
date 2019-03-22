//
//  WLUsersProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLUsersProviderDelegate;

@protocol WLUsersProvider <NSObject>

- (void)tryRefreshUsersWithKeyId:(NSString *)kid;
- (void)tryHisUsersWithKeyId:(NSString *)kid;
- (void)setListener:(id<WLUsersProviderDelegate>)delegate;
- (void)stop;

@end
