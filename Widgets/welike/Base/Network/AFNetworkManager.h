//
//  AFNetworkManager.h
//  AppFramework
//
//  Created by liubin on 13-1-10.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHttpMacros.h"
#import "HLNetWorkReachability.h"

@class AFHttpEngine;
@class AFHttpOperation;


@protocol AFNetworkManagerDelegate <NSObject>

- (void)reachabilityChanged:(HLNetWorkStatus)status;

@end

@interface AFNetworkManager : NSObject
{
    unsigned long long _allFlowSize;
}

@property (nonatomic, readonly) unsigned long long allFlowSize;

// methods
- (void)registerReachabilityNotification:(id<AFNetworkManagerDelegate>)observer;
- (void)removeReachabilityNotification:(id<AFNetworkManagerDelegate>)observer;
- (void)addHttpEngineObserver:(AFHttpEngine *)engine;
- (void)removeHttpEngineObserver:(AFHttpEngine *)engine flowSize:(size_t)size;
- (HLNetWorkStatus)reachabilityStatus;
- (NSString *)getNetType;
+ (NSString *)getCarrierName;
- (void)addHttpOperation:(AFHttpOperation *)operation;
- (void)cancelAll;

// singleton methods
+ (AFNetworkManager *)getInstance;

+(void)logNumOfRequst;

@end
