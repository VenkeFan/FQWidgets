//
//  WLTracker.m
//  welike
//
//  Created by 刘斌 on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTracker.h"
#import "WLTrackerCache.h"
#import "WLTrackRequest.h"

static WLTracker *_gTracker = nil;

@interface WLTracker () <WLTrackerCacheDelegate>
{
    BOOL isSending;
}

@property (nonatomic, strong) WLTrackerCache *cache;

@end

@implementation WLTracker

+ (WLTracker *)getInstance
{
    if (!_gTracker)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gTracker = [[WLTracker alloc] init];
        });
    }
    
    return _gTracker;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_gTracker)
        {
            _gTracker = [super allocWithZone:zone];
            return _gTracker;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _gTracker;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cache = [[WLTrackerCache alloc] init];
        self.cache.delegate = self;
    }
    return self;
}

- (void)setEntrance:(WELIKE_APP_ENTRANCE)entrance
{
    self.cache.entrance = entrance;
}

- (void)appendEventId:(NSString *)eventId eventInfo:(NSDictionary *)eventInfo
{
    [self.cache appendEventId:eventId eventInfo:eventInfo];
}

- (void)synchronize
{
    //通过变量控制请求结束后再去进行下次打点
    if (isSending == NO)
    {
       isSending = YES;
//        NSLog(@"执行了1");
        [self trackerCacheSynchronize];
    }
}

- (void)trackerCacheSynchronize
{
    [self.cache listTrackLogs:^(WLTrackerList *list) {
//          NSLog(@"执行了2");
        if ([list.logs count] > 0)
        {
            __weak typeof(self) weakSelf = self;
            WLTrackRequest *request = [[WLTrackRequest alloc] initTrackRequest];
            [request sendTracks:list.logs successed:^{
                if ([list.trackIds count] > 0)
                {
                    [weakSelf.cache remove:list.trackIds finish:^{
                        
                        for (int i = 0; i < [list.logs count]; i++)
                        {
                            //NSDictionary *dic = list.logs[i];
                           // NSLog(@"已经删除的%@",[dic objectForKey:@"ctime"]);
                        }
                        
                        self->isSending = NO;
                    }];
                }
                
            } error:^(NSInteger errorCode) {
                self->isSending = NO;
            }];
        }
        else
        {
            self->isSending = NO;
        }
    }];
}

@end
