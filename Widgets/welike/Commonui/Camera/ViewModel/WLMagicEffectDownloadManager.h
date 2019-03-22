//
//  WLMagicEffectDownloadManager.h
//  welike
//
//  Created by fan qi on 2018/11/30.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLMagicEffectCacheManager.h"

@class WLMagicEffectDownloadManager;

@protocol WLMagicEffectDownloadManagerDelegate <NSObject>

- (void)magicEffectDownloadManagerDownloading:(NSString *)requestUrlPath
                                     progress:(CGFloat)progress;
- (void)magicEffectDownloadManagerDidCompleted:(NSString *)requestUrlPath
                                       dstPath:(NSString *)dstPath
                                         error:(NSError *)error;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLMagicEffectDownloadManager : NSObject

- (void)downloadEffect:(WLMagicBasicModel *)effectModel;
- (void)cancelAll;

@property (nonatomic, weak) id<WLMagicEffectDownloadManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
