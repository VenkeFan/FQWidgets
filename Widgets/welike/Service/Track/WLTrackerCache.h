//
//  WLTrackerCache.h
//  welike
//
//  Created by 刘斌 on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@protocol WLTrackerCacheDelegate <NSObject>

- (void)trackerCacheSynchronize;

@end

@interface WLTrackerList : NSObject

@property (nonatomic, strong) NSArray<NSDictionary*> *logs;
@property (nonatomic, strong) NSArray<NSNumber*> *trackIds;

@end

@interface WLTrackerCache : NSObject

@property (nonatomic, assign) WELIKE_APP_ENTRANCE entrance;
@property (nonatomic, weak) id<WLTrackerCacheDelegate> delegate;

- (void)appendEventId:(NSString *)eventId eventInfo:(NSDictionary *)eventInfo;
- (void)synchronize;
- (void)listTrackLogs:(void(^)(WLTrackerList *list))block;
- (void)remove:(NSArray<NSNumber*> *)ids finish:(void (^)(void))callback;



@end
