//
//  WLPostsProviderBase.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLPostsProviderBase : NSObject

@property (nonatomic, strong) NSMutableDictionary *cacheList;
@property (nonatomic, strong) NSMutableDictionary *onePageList;

- (NSArray *)filterPosts:(NSArray *)source;
- (void)cacheFirstPage:(NSArray *)source;
- (NSInteger)refreshNewCount:(NSArray *)source;
+ (NSArray *)filterPosts:(NSArray *)source filter:(NSMutableDictionary *)filter;

@end
