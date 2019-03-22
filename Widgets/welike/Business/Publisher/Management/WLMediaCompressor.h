//
//  WLMediaCompressor.h
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDraft.h"

@protocol WLMediaCompressorDelegate <NSObject>

- (void)onMediaCompressor:(NSString *)draftId process:(CGFloat)process;
- (void)onMediaCompressor:(NSString *)draftId completed:(NSMutableDictionary *)compressMap;

@end

@interface WLMediaCompressedObj : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@interface WLMediaCompressor : NSObject

@property (nonatomic, assign) NSInteger compressStartTime;//video
@property (nonatomic, assign) NSInteger compressEndTime;//video
@property (nonatomic, assign) NSInteger compressLength;//video,image


@property (nonatomic, weak) id<WLMediaCompressorDelegate> delegate;

- (void)compress:(WLPostDraft *)draft;

@end
