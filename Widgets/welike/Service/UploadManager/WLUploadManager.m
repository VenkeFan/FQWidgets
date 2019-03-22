//
//  WLUploadManager.m
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUploadManager.h"
#import "WLUploadTrans.h"
#import "WLUploadStatusStorage.h"
#import "LuuUtils.h"
#import <AliyunOSSiOS/OSSService.h>

#define UPLOAD_TASKS_NUM          3

@interface WLUploadManager () <WLUploadTransDelegate>

@property (nonatomic, strong) NSMutableArray *waitingTasks;
@property (nonatomic, strong) NSMutableDictionary *runningTasks;
@property (nonatomic, strong) WLUploadStatusStorage *uploadStatusStorage;
@property (nonatomic, strong) NSPointerArray *delegates;


- (void)startTask:(WLUploadTrans *)trans;
- (WLUploadTrans *)removeWaitingTransForSign:(NSString *)sign;
- (void)next;
+ (NSString *)signWithObjFileName:(NSString *)objFileName objKey:(NSString *)objKey;
+ (NSString *)buildObjectKey:(NSString *)subObjectKey extName:(NSString *)extName objectType:(NSString *)objectType;

@end

@implementation WLUploadManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.waitingTasks = [NSMutableArray array];
        self.runningTasks = [NSMutableDictionary dictionary];
        self.uploadStatusStorage = [[WLUploadStatusStorage alloc] init];
        self.delegates = [NSPointerArray weakObjectsPointerArray];
        
        //开始上传
        id<OSSCredentialProvider> credentialProvider = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:[AppContext getSts]];
        OSSClientConfiguration *cfg = [[OSSClientConfiguration alloc] init];
        cfg.maxRetryCount = 3;
        cfg.timeoutIntervalForRequest = 60;
        cfg.isHttpdnsEnable = NO;
        cfg.crc64Verifiable = YES;
        
        self.defaultClient = [[OSSClient alloc] initWithEndpoint:[AppContext getEndPoint] credentialProvider:credentialProvider clientConfiguration:cfg];
    }
    return self;
}

- (void)prepare
{
    [self.uploadStatusStorage prepare];
}

#pragma mark WLUploadManager public methods
- (void)registerDelegate:(id<WLUploadManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        if ([self.delegates containsObject:delegate] == NO)
        {
            [self.delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLUploadManagerDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        [self.delegates removeObject:delegate];
    }
}

- (NSString *)uploadWithFileName:(NSString *)objFileName objectType:(NSString *)objectType
{
    return [self uploadWithObjectKey:nil objFileName:objFileName objectType:objectType];
}

- (NSString *)uploadWithObjectKey:(NSString *)objectKey objFileName:(NSString *)objFileName objectType:(NSString *)objectType
{
    NSString *objKey = nil;
    if ([objFileName length] > 0)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:objFileName] == NO) return objKey;
        
        NSString *sign = nil;
        if ([objectKey length] > 0)
        {
            objKey = [objectKey copy];
            sign = [WLUploadManager signWithObjFileName:objFileName objKey:objectKey];
        }
        else
        {
            objKey = [WLUploadManager buildObjectKey:[LuuUtils uuid] extName:[objFileName pathExtension] objectType:objectType];
            sign = [WLUploadManager signWithObjFileName:objFileName objKey:objKey];
        }
        WLUploadTrans *trans = nil;
        NSString *k = [self.uploadStatusStorage getMultiPartStatus:sign];
        if ([k length] > 0 && [k isEqualToString:objKey] == YES)
        {
            trans = [[WLUploadTrans alloc] initWithFileName:objFileName objectKey:objKey sign:sign resume:YES];
        }
        else
        {
            trans = [[WLUploadTrans alloc] initWithFileName:objFileName objectKey:objKey sign:sign resume:NO];
        }
        NSInteger runningCount = 0;
        @synchronized (self.runningTasks)
        {
            runningCount = [self.runningTasks count];
        }
        if (runningCount < UPLOAD_TASKS_NUM)
        {
            [self startTask:trans];
        }
        else
        {
            [self.waitingTasks addObject:trans];
        }
    }
    return objKey;
}

- (void)removeWithObjectKey:(NSString *)objectKey objFileName:(NSString *)objFileName
{
    NSString *sign = [WLUploadManager signWithObjFileName:objFileName objKey:objectKey];
    WLUploadTrans *trans = [self removeWaitingTransForSign:sign];
    if (trans != nil)
    {
        [self.uploadStatusStorage removeMultiPartStatusForSign:trans.sign];
    }
    else
    {
        @synchronized (self.runningTasks)
        {
            trans = [self.runningTasks objectForKey:sign];
            if (trans != nil)
            {
                [self.runningTasks removeObjectForKey:sign];
                [trans stop];
                [self.uploadStatusStorage removeMultiPartStatusForSign:trans.sign];
            }
        }
    }
}

#pragma mark WLUploadTransDelegate methods
- (void)onUploadTrans:(WLUploadTrans *)trans successed:(NSString *)url
{
    BOOL checkCompleted = NO;
    @synchronized (self.runningTasks)
    {
        if ([self.runningTasks objectForKey:trans.sign] != nil)
        {
            checkCompleted = YES;
            [self.runningTasks removeObjectForKey:trans.sign];
            trans.delegate = nil;
        }
    }
    if (checkCompleted == YES)
    {
        [self.uploadStatusStorage removeMultiPartStatusForSign:trans.sign];
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLUploadManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onUploadingKey:completed:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate onUploadingKey:trans.objectKey completed:url];
                    });
                }
            }
        }
        [self next];
    }
}

- (void)onUploadTrans:(WLUploadTrans *)trans process:(CGFloat)process
{
    BOOL checkContain = NO;
    @synchronized (self.runningTasks)
    {
        if ([self.runningTasks objectForKey:trans.sign] != nil)
        {
            checkContain = YES;
        }
    }
    if (checkContain == YES)
    {
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLUploadManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onUploadingKey:process:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate onUploadingKey:trans.objectKey process:process];
                    });
                }
            }
        }
    }
}

- (void)onUploadTrans:(WLUploadTrans *)trans failed:(NSInteger)errorCode
{
    BOOL checkFailed = NO;
    @synchronized (self.runningTasks)
    {
        if ([self.runningTasks objectForKey:trans.sign] != nil)
        {
            checkFailed = YES;
            [self.runningTasks removeObjectForKey:trans.sign];
            trans.delegate = nil;
        }
    }
    if (checkFailed == YES)
    {
        @synchronized (self.delegates)
        {
            for (NSInteger i = 0; i < [self.delegates count]; i++)
            {
                id<WLUploadManagerDelegate> delegate = [self.delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(onUploadingKey:failed:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate onUploadingKey:trans.objectKey failed:errorCode];
                    });
                }
            }
        }
        [self next];
    }
}

#pragma mark WLUploadManager private methods
- (void)startTask:(WLUploadTrans *)trans
{
    [self removeWaitingTransForSign:trans.sign];
    @synchronized (self.runningTasks)
    {
        [self.runningTasks setObject:trans forKey:trans.sign];
    }
    trans.delegate = self;
    if ([trans isResume] == YES)
    {
        [trans resume];
    }
    else
    {
        [trans start];
        [self.uploadStatusStorage putMultiPartStatus:trans.objectKey forSign:trans.sign];
    }
}

- (WLUploadTrans *)removeWaitingTransForSign:(NSString *)sign
{
    @synchronized (self.waitingTasks)
    {
        NSInteger idx = -1;
        for (NSInteger i = 0; i < [self.waitingTasks count]; i++)
        {
            WLUploadTrans *trans = [self.waitingTasks objectAtIndex:i];
            if ([trans.sign isEqualToString:sign] == YES)
            {
                idx = i;
                break;
            }
        }
        if (idx != -1)
        {
            WLUploadTrans *trans = [self.waitingTasks objectAtIndex:idx];
            [self.waitingTasks removeObjectAtIndex:idx];
            return trans;
        }
    }
    return nil;
}

- (void)next
{
    NSInteger runningCount = 0;
    @synchronized (self.runningTasks)
    {
        runningCount = [self.runningTasks count];
    }
    if (runningCount < UPLOAD_TASKS_NUM)
    {
        WLUploadTrans *trans = nil;
        @synchronized (self.waitingTasks)
        {
            if ([self.waitingTasks count] > 0)
            {
                trans = [self.waitingTasks objectAtIndex:0];
                [self.waitingTasks removeObjectAtIndex:0];
            }
        }
        if (trans != nil)
        {
            [self startTask:trans];
        }
    }
}

+ (NSString *)signWithObjFileName:(NSString *)objFileName objKey:(NSString *)objKey
{
    NSString *ss = [NSString stringWithFormat:@"%@%@", [LuuUtils md5Encode:objFileName], [LuuUtils md5Encode:objKey]];
    return [LuuUtils md5Encode:ss];
}

+ (NSString *)buildObjectKey:(NSString *)subObjectKey extName:(NSString *)extName objectType:(NSString *)objectType
{
    NSString *objKey = nil;
    if ([extName length] > 0)
    {
        objKey = [NSString stringWithFormat:@"%@-%@.%@", objectType, subObjectKey, extName];
    }
    else
    {
        objKey = [NSString stringWithFormat:@"%@-%@", objectType, subObjectKey];
    }
    return objKey;
}


@end
