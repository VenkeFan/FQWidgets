//
//  WLCommentsProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLCommentsProviderDelegate;

@protocol WLCommentsProvider <NSObject>

- (void)tryRefreshCommentsForPid:(NSString *)pid;
- (void)tryHisCommentsForPid:(NSString *)pid;
- (void)setListener:(id<WLCommentsProviderDelegate>)delegate;
- (void)stop;

@end
