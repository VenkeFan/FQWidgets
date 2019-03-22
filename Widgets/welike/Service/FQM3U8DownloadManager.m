//
//  FQM3U8DownloadManager.m
//  welike
//
//  Created by fan qi on 2018/9/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVideoDownloadManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FQM3U8DownloadManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray<NSString *> *segmentUrlStrArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *segmentUrlStrDic;
@property (nonatomic, strong) NSMutableData *fileData;

@end

@implementation FQM3U8DownloadManager {
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
    
    if (![[self.downloadUrlString lowercaseString] hasSuffix:kM3U8Suffix]) {
        return NO;
    }
    
    _isDownloading = YES;
    
    [self p_parseUrlString:self.downloadUrlString];
    
    return YES;
}

- (void)cancel {
    [_session invalidateAndCancel];
    _isDownloading = NO;
}

#pragma mark - Parse

- (void)p_parseUrlString:(NSString *)urlString {
    NSURL *downUrl = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_queue_create("com.welike.m3u8parse.fq", DISPATCH_QUEUE_SERIAL), ^{
        NSString *parsedStr = [[NSString alloc] initWithContentsOfURL:downUrl encoding:NSUTF8StringEncoding error:nil];
        if (parsedStr.length == 0) {
            return;
        }
        
        NSRange infoRange = [parsedStr rangeOfString:kM3U8EXTINF];
        if (NSNotFound == infoRange.location) {
            NSRange streamInfoRange = [parsedStr rangeOfString:kM3U8EXT_X_STREAM_INF];
            if (NSNotFound != streamInfoRange.location) {
                NSArray<NSString *> *infoArray = [parsedStr componentsSeparatedByString:@"\n"];
                
                __block NSString *newSuffix = nil;
                [infoArray enumerateObjectsWithOptions:NSEnumerationReverse
                                            usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                if (obj.length != 0) {
                                                    newSuffix = obj;
                                                    *stop = YES;
                                                }
                                            }];
                
                NSString *newUrlStr = [urlString stringByReplacingOccurrencesOfString:urlString.lastPathComponent withString:newSuffix];
                NSString *newParsedStr = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:newUrlStr] encoding:NSUTF8StringEncoding error:nil];
                if (newParsedStr.length == 0) {
                    return;
                }
                
                NSRange newRange = [newParsedStr rangeOfString:kM3U8EXTINF];
                if (NSNotFound != newRange.location) {
                    [self p_parseSegmentUrlStrFromUrlStr:newUrlStr range:newRange infoStr:newParsedStr];
                }
            }
        } else {
            [self p_parseSegmentUrlStrFromUrlStr:urlString range:infoRange infoStr:parsedStr];
        }
    });
}

- (void)p_parseSegmentUrlStrFromUrlStr:(NSString *)urlStr range:(NSRange)infoRange infoStr:(NSString *)infoStr {
    [self.segmentUrlStrArray removeAllObjects];
    
    if (urlStr.length == 0 || infoStr.length == 0) {
        return;
    }
    
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:kM3U8EXTINF
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
    if (error) {
        return;
    }
    
    NSArray<NSTextCheckingResult *> *resultArray = [regular matchesInString:infoStr options:0 range:NSMakeRange(0, infoStr.length)];
    for (int i = 0; i < resultArray.count; i++) {
        NSUInteger startLoc = resultArray[i].range.location + resultArray[i].range.length;
        NSUInteger length = 0;
        
        if (i == resultArray.count - 1) {
            NSRange endRange = [infoStr rangeOfString:kM3U8EXTEND];
            length = endRange.location - startLoc;
        } else {
            length = resultArray[i + 1].range.location - startLoc;
        }
        
        NSString *segment = [infoStr substringWithRange:NSMakeRange(startLoc, length)];
        if (!segment) {
            continue;
        }
        
        NSArray<NSString *> *components = [segment componentsSeparatedByString:@","];
        
        if (components.count >= 2) {
//            NSString *duration = components.firstObject;
            
            NSString *newSuffix = [components[1] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if (newSuffix) {
                NSString *newUrlStr = [urlStr stringByReplacingOccurrencesOfString:urlStr.lastPathComponent withString:newSuffix];
                if (newUrlStr) {
                    [self.segmentUrlStrArray addObject:newUrlStr];
                }
            }
        }
    }
    
    [self p_downloadSegment];
}

#pragma mark - Download

static NSUInteger count = 0;

- (void)p_downloadSegment {
    count = 0;
    
    [self.segmentUrlStrArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *downUrl = [NSURL URLWithString:obj];
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:downUrl];
        task.taskDescription = [self p_keyFromIndex:idx];
        [task resume];
    }];
}

- (void)p_allSegmentsDownloaded {
    for (NSUInteger i = 0; i < self.segmentUrlStrDic.allKeys.count; i++) {
        NSString *key = [self p_keyFromIndex:i];
        if (self.segmentUrlStrDic[key].length == 0) {
            continue;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.segmentUrlStrDic[key]]];
        if (!data) {
            continue;
        }
        [self.fileData appendData:data];
        
        [[NSFileManager defaultManager] removeItemAtPath:self.segmentUrlStrDic[key] error:nil];
    }
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:self.segmentUrlStrArray.lastObject.lastPathComponent];
    
    [self.fileData writeToFile:filePath options:NSDataWritingAtomic error:nil];
    
    [self convertToMP4:filePath
                 saved:YES
              finished:^(BOOL succeed, NSURL *exportPathUrl, NSError *error) {
                  
              }];;
}

- (NSString *)p_keyFromIndex:(NSUInteger)index {
    return [NSString stringWithFormat:@"%lu", (unsigned long)index];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    count++;
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:nil];
    
    [fileManager moveItemAtPath:location.path toPath:filePath error:&error];
    
    [self.segmentUrlStrDic setObject:filePath forKey:downloadTask.taskDescription];
    
    if (error) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_save_error"
                                                                         fileName:@"pic_sel"]];
        
        if ([self.delegate respondsToSelector:@selector(videoDownloadManagerDidCompleted:error:)]) {
            [self.delegate videoDownloadManagerDidCompleted:self error:error];
        }
    } else {
        
    }
    
    if (count == self.segmentUrlStrArray.count) {
        [self p_allSegmentsDownloaded];
    } else {
        if ([self.delegate respondsToSelector:@selector(videoDownloadManager:progress:)]) {
            [self.delegate videoDownloadManager:self progress:count / (float)self.segmentUrlStrArray.count];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
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

- (NSMutableArray<NSString *> *)segmentUrlStrArray {
    if (!_segmentUrlStrArray) {
        _segmentUrlStrArray = [NSMutableArray array];
    }
    return _segmentUrlStrArray;
}

- (NSMutableDictionary<NSString *,NSString *> *)segmentUrlStrDic {
    if (!_segmentUrlStrDic) {
        _segmentUrlStrDic = [NSMutableDictionary dictionary];
    }
    return _segmentUrlStrDic;
}

- (NSMutableData *)fileData {
    if (!_fileData) {
        _fileData = [NSMutableData data];
    }
    return _fileData;
}

@end
