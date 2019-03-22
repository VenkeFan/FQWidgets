//
//  WLUsersProviderBase.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLUsersProviderBase : NSObject

@property (nonatomic, strong) NSMutableDictionary *cacheList;
@property (nonatomic, strong) NSMutableDictionary *onePageList;

- (NSArray *)filterUsers:(NSArray *)source;
- (void)cacheFirstPage:(NSArray *)source;
- (NSInteger)refreshNewCount:(NSArray *)source;
+ (NSArray *)filterUsers:(NSArray *)source filter:(NSMutableDictionary *)filter;

@end
