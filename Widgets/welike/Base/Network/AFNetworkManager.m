//
//  AFNetworkManager.m
//  AppFramework
//
//  Created by liubin on 13-1-10.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#import "AFNetworkManager.h"
#import "AFHttpOperation.h"
#import<CoreTelephony/CTCarrier.h>
#import<CoreTelephony/CTTelephonyNetworkInfo.h>


static AFNetworkManager *_gNetworkMgr = nil;

@interface AFNetworkManager ()

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *engines;
@property (nonatomic, strong) NSOperationQueue *operationsQueue;
@property (nonatomic, strong) HLNetWorkReachability *reach;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
@property (nonatomic, copy) NSString *netType;


@end

@implementation AFNetworkManager

@synthesize allFlowSize = _allFlowSize;
@synthesize notifications = _notifications;
@synthesize engines = _engines;
@synthesize operationsQueue = _operationsQueue;
@synthesize reach = _reach;

- (id)init
{
    self = [super init];
    if (self)
    {
        _allFlowSize = 0;

        self.notifications = [[NSMutableArray alloc] init];
        self.engines = [[NSMutableArray alloc] initWithCapacity:10];

        self.operationsQueue = [[NSOperationQueue alloc] init];
        [self.operationsQueue setMaxConcurrentOperationCount:3];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kNetWorkReachabilityChangedNotification
                                                   object:nil];

        self.reach = [HLNetWorkReachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reach startNotifier];
        
        self.telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.operationsQueue cancelAllOperations];
    self.operationsQueue = nil;
}

#pragma mark AFHttpManager methods
- (void)registerReachabilityNotification:(id<AFNetworkManagerDelegate>)observer
{
    @synchronized(self.notifications)
    {
        if (![self.notifications containsObject:observer])
        {
            [self.notifications addObject:observer];
        }
    }
}

- (void)removeReachabilityNotification:(id<AFNetworkManagerDelegate>)observer
{
    @synchronized(self.notifications)
    {
        if ([self.notifications containsObject:observer])
        {
            [self.notifications removeObject:observer];
        }
    }
}

- (void)addHttpEngineObserver:(AFHttpEngine *)engine
{
    if (!engine) return;

    @synchronized(self.engines)
    {
        if (![self.engines containsObject:engine])
        {
            [self.engines addObject:engine];
        }
    }
}

- (void)removeHttpEngineObserver:(AFHttpEngine *)engine flowSize:(size_t)size
{
    _allFlowSize += size;

    if (!engine) return;

    @synchronized(self.engines)
    {
        if ([self.engines containsObject:engine])
        {
            [self.engines removeObject:engine];
        }
    }
}

- (HLNetWorkStatus)reachabilityStatus
{
    return [self.reach currentReachabilityStatus];
}

- (NSString *)getNetType
{
    if (_netType.length > 0)
    {
        return _netType;
    }
    else
    {
        return @"";
    }
}

+ (NSString *)getCarrierName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];

    NSString *mobile;
    
    if (!carrier.isoCountryCode)
    {
        mobile = @"";
    }
    else
    {
        mobile = [carrier carrierName];
    }
    return mobile;
}

- (void)addHttpOperation:(AFHttpOperation *)operation
{
    @synchronized(self.operationsQueue)
    {
        // Only one kind of operation is running at the same time.
        NSArray *queue = [self.operationsQueue operations];
        int count = (int)[queue count];
//        NSLog(@"=========net loading:%ld",(long)count);
        for (int i = count - 1; i >= 0; i--)
        {
            AFHttpOperation *one = [queue objectAtIndex:i];
            if (one.type == operation.type)
            {
                [operation addDependency:one];
                break;
            }
        }
        
        [self.operationsQueue addOperation:operation];
    }
}

- (void)cancelAll
{
    @synchronized(self.operationsQueue)
    {
        [self.operationsQueue cancelAllOperations];
    }
    @synchronized(self.engines)
    {
        [self.engines removeAllObjects];
    }
}

#pragma mark Reachability callback methods
- (void)reachabilityChanged:(NSNotification *)notification
{
    HLNetWorkReachability *curReach = [notification object];
    HLNetWorkStatus netStatus = [curReach currentReachabilityStatus];
   
    @synchronized(self.notifications)
    {
        for (id<AFNetworkManagerDelegate> observer in self.notifications)
        {
            if ([observer respondsToSelector:@selector(reachabilityChanged:)])
            {
                [observer reachabilityChanged:netStatus];
            }
        }
    }
    
    switch (netStatus) {
        case HLNetWorkStatusNotReachable:
            _netType = @"No Network";
            break;
        case HLNetWorkStatusUnknown:
            _netType = @"Unkown";
            break;
        case HLNetWorkStatusWWAN2G:
          
            _netType = @"2G";
            break;
        case HLNetWorkStatusWWAN3G:
          
            _netType = @"3G";
            break;
        case HLNetWorkStatusWWAN4G:
           
            _netType = @"4G";
            break;
        case HLNetWorkStatusWiFi:
            _netType = @"WiFi";
            break;
            
        default:
            break;
    }
}

#pragma mark AFNetworkManager singleton methods
+ (AFNetworkManager *)getInstance
{
    if (!_gNetworkMgr)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gNetworkMgr = [[AFNetworkManager alloc] init];
        });
    }
    
    return _gNetworkMgr;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_gNetworkMgr)
        {
            _gNetworkMgr = [super allocWithZone:zone];
            return _gNetworkMgr;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _gNetworkMgr;
}

+(void)logNumOfRequst
{
#if DEBUG
//    NSArray *queue = [[AFNetworkManager getInstance].operationsQueue operations];
//    int count = (int)[queue count];
//    NSLog(@"remain========net loading:%ld",(long)count);
#endif
}

@end
