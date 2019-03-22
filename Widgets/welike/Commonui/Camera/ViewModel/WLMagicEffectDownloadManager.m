//
//  WLMagicEffectDownloadManager.m
//  welike
//
//  Created by fan qi on 2018/11/30.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicEffectDownloadManager.h"

@interface WLMagicEffectDownloadManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) WLMagicBasicModelType effectType;

@end

@implementation WLMagicEffectDownloadManager

- (void)dealloc {
    [_session invalidateAndCancel];
}

- (void)cancelAll {
    [_session invalidateAndCancel];
}

- (void)downloadEffect:(WLMagicBasicModel *)effectModel {
    if (effectModel.resourceUrl.length == 0) {
        return;
    }
    
    NSString *dstPath = nil;
    if ([[WLMagicEffectCacheManager instance] isExist:effectModel.resourceUrl effectType:effectModel.type dstPath:&dstPath]) {
        if ([self.delegate respondsToSelector:@selector(magicEffectDownloadManagerDidCompleted:dstPath:error:)]) {
            [self.delegate magicEffectDownloadManagerDidCompleted:effectModel.resourceUrl dstPath:dstPath error:nil];
        }
        return;
    }
    
    self.effectType = effectModel.type;
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:[NSURL URLWithString:effectModel.resourceUrl]];
    
    [task resume];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [[WLMagicEffectCacheManager instance] moveFileAtPath:location.path
                                         toPathComponent:downloadTask.response.URL.absoluteString
                                              effectType:self.effectType
                                               completed:^(NSString * _Nonnull dstPath) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if ([self.delegate respondsToSelector:@selector(magicEffectDownloadManagerDidCompleted:dstPath:error:)]) {
                                                           [self.delegate magicEffectDownloadManagerDidCompleted:downloadTask.currentRequest.URL.absoluteString dstPath:dstPath error:downloadTask.error];
                                                       }
                                                   });
                                               }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(magicEffectDownloadManagerDownloading:progress:)]) {
            [self.delegate magicEffectDownloadManagerDownloading:downloadTask.currentRequest.URL.absoluteString progress:totalBytesWritten / (float)totalBytesExpectedToWrite];
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

#pragma mark - Getter

- (NSURLSession *)session {
    if (!_session) {
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 5;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:operationQueue];
    }
    return _session;
}

@end
