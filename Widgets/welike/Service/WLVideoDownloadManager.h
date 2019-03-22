//
//  WLVideoDownloadManager.h
//  welike
//
//  Created by fan qi on 2018/6/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kM3U8Suffix;
extern NSString * const kTSSuffix;
extern NSString * const kM3U8EXTINF;
extern NSString * const kM3U8EXT_X_STREAM_INF;
extern NSString * const kM3U8EXTEND;

@class WLVideoDownloadAbstractManager;

@protocol WLVideoDownloadManagerDelegate <NSObject>

- (void)videoDownloadManager:(WLVideoDownloadAbstractManager *)manager progress:(CGFloat)progress;
- (void)videoDownloadManagerDidCompleted:(WLVideoDownloadAbstractManager *)manager error:(NSError *)error;

@end

@interface WLVideoDownloadAbstractManager : NSObject

@property (nonatomic, copy) NSString *downloadUrlString;
@property (nonatomic, assign, readonly) BOOL isDownloading;
@property (nonatomic, weak) id<WLVideoDownloadManagerDelegate> delegate;

- (BOOL)start;
- (void)cancel;

- (void)convertToMP4:(NSString *)fileUrlStr
               saved:(BOOL)saved
            finished:(void(^)(BOOL succeed, NSURL *exportPathUrl, NSError *error))finished;
- (void)saveVideoToPhotoLibrary:(NSURL *)fileUrl
                       finished:(void (^)(NSError *error))finished;

@end

@interface WLVideoDownloadManager : WLVideoDownloadAbstractManager

@end

@interface FQM3U8DownloadManager : WLVideoDownloadAbstractManager

@end
