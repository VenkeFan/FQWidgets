//
//  WLVideoDownloadManager.m
//  welike
//
//  Created by fan qi on 2018/6/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVideoDownloadManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

NSString * const kM3U8Suffix                = @".m3u8";
NSString * const kTSSuffix                  = @".ts";
NSString * const kM3U8EXTINF                = @"#EXTINF:";
NSString * const kM3U8EXT_X_STREAM_INF      = @"#EXT-X-STREAM-INF:";
NSString * const kM3U8EXTEND                = @"#EXT-X-ENDLIST";

@interface WLVideoDownloadAbstractManager ()

@end

@implementation WLVideoDownloadAbstractManager

- (BOOL)start {
    return NO;
}

- (void)cancel {
    
}

- (void)convertToMP4:(NSString *)fileUrlStr saved:(BOOL)saved finished:(void (^)(BOOL, NSURL *, NSError *))finished {
    
}


- (void)saveVideoToPhotoLibrary:(NSURL *)fileUrl finished:(void (^)(NSError *error))finished {
    if (@available(iOS 9.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) {
                return;
            }
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                options.originalFilename = fileUrl.path;
                
                [request addResourceWithType:PHAssetResourceTypeVideo
                                     fileURL:fileUrl
                                     options:options];
                
            } completionHandler:^(BOOL success, NSError * _Nullable error ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finished) {
                        finished(error);
                    }
                });
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc] init];
        [lab writeVideoAtPathToSavedPhotosAlbum:fileUrl
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (finished) {
                                            finished(error);
                                        }
                                    });
                                }];
    }
}

@end

@interface WLVideoDownloadManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation WLVideoDownloadManager {
    BOOL _isDownloading;
}

- (instancetype)init {
    if (self = [super init]) {
        _isDownloading = NO;
    }
    return self;
}

- (void)dealloc {
    [_session invalidateAndCancel];
}

#pragma mark - Public

- (BOOL)start {
    if (_isDownloading) {
        return NO;
    }
    
    if (self.downloadUrlString.length == 0) {
        return NO;
    }
    
    NSURL *downUrl = [NSURL URLWithString:self.downloadUrlString];
    
    _downloadTask = [self.session downloadTaskWithURL:downUrl];
    [_downloadTask resume];
    
    _isDownloading = YES;
    
    return YES;
}

- (void)cancel {
    [_downloadTask cancel];
    [_session invalidateAndCancel];
    _isDownloading = NO;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    _isDownloading = NO;
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:nil];

    [fileManager moveItemAtPath:location.path toPath:filePath error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    } else {
        if ([filePath hasSuffix:kTSSuffix]) {
            [self convertToMP4:filePath
                         saved:YES
                      finished:^(BOOL succeed, NSURL *exportPathUrl, NSError *error) {
                          
                      }];
        } else {
            [self saveVideoToPhotoLibrary:[NSURL fileURLWithPath:filePath]
                                 finished:^(NSError *error) {
                                     if(error) {
                                         NSLog(@"%@", error);
                                     } else {
                                         NSLog(@"保存成功");
                                     }
                                     
                                     if ([self.delegate respondsToSelector:@selector(videoDownloadManagerDidCompleted:error:)]) {
                                         [self.delegate videoDownloadManagerDidCompleted:self error:error];
                                     }
                                     
                                     [fileManager removeItemAtPath:filePath error:nil];
                                 }];
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if ([self.delegate respondsToSelector:@selector(videoDownloadManager:progress:)]) {
        [self.delegate videoDownloadManager:self progress:totalBytesWritten / (float)totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

#pragma mark - Getter

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

@end
