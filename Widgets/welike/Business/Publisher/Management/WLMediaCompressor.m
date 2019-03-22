//
//  WLMediaCompressor.m
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMediaCompressor.h"
#import "WLImageHelper.h"

@implementation WLMediaCompressedObj

@end

@interface WLMediaCompressor ()
{
    dispatch_queue_t _compressQueue;
    WLPostDraft *compressDraft;
}

@property (nonatomic, copy) NSString *draftId;
@property (nonatomic, strong) NSMutableDictionary *compressMap;
@property (nonatomic, assign) NSInteger count;

- (void)handleImageEncodeWithFileName:(NSString *)fileName size:(CGSize)size localIdentifier:(NSString *)localIdentifier allPicCount:(NSInteger)picCount isSuccessed:(BOOL)isSuccessed;
- (void)videoEncoding:(AVAssetExportSession *)session fileName:(NSString *)fileName localIdentifier:(NSString *)localIdentifier;
- (void)handleVideoEncode:(AVAssetExportSession *)session fileName:(NSString *)fileName localIdentifier:(NSString *)localIdentifier;

@end

@implementation WLMediaCompressor

- (id)init
{
    self = [super init];
    if (self)
    {
        self.compressMap = [NSMutableDictionary dictionary];
        _compressQueue = dispatch_queue_create("welike.media.compress", DISPATCH_QUEUE_CONCURRENT);
        self.count = 0;
    }
    return self;
}

- (void)compress:(WLPostDraft *)draft
{
    compressDraft = draft;
    self.draftId = draft.draftId;
    if ([draft.picDraftList count] > 0)
    {
        NSInteger picCount = 0;//[draft.picDraftList count];
        for (NSInteger i = 0; i < [draft.picDraftList count]; i++)
        {
            WLAttachmentDraft *picDraft = [draft.picDraftList objectAtIndex:i];
             if (picDraft.url == nil || [picDraft.url length] == 0)
             {
                 picCount ++;
             }
        }
        
        for (NSInteger i = 0; i < [draft.picDraftList count]; i++)
        {
            WLAttachmentDraft *picDraft = [draft.picDraftList objectAtIndex:i];
            if (picDraft.url == nil || [picDraft.url length] == 0)
            {
                __weak typeof(self) weakSelf = self;
                NSString *localIdentifier = [picDraft.asset.localIdentifier copy];
                NSString *name = nil;
                if ([[picDraft.asset valueForKey:@"filename"] hasSuffix:@"GIF"])
                {
                    name = [NSString stringWithFormat:@"%@.gif", [LuuUtils md5Encode:localIdentifier]];
                }
                else
                {
                    name = [NSString stringWithFormat:@"%@.jpg", [LuuUtils md5Encode:localIdentifier]];
                }
                NSString *fileName = [[AppContext getCachePath] stringByAppendingPathComponent:name];
                dispatch_async(_compressQueue, ^{
                    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName] == YES)
                    {
                        UIImage *img = [[UIImage alloc] initWithContentsOfFile:fileName];
                        CGSize size = CGSizeMake(img.size.width, img.size.height);
                        dispatch_async(dispatch_get_main_queue(), ^{
                             picDraft.attachDataSize = (UIImageJPEGRepresentation(img, 1).length)/1024;
                            [weakSelf handleImageEncodeWithFileName:fileName size:size localIdentifier:localIdentifier allPicCount:picCount isSuccessed:YES];
                        });
                    }
                    else
                    {
                        [WLImageHelper imageCompressAndLocalSave:picDraft.asset withSavePath:fileName result:^(BOOL result,CGSize size,CGFloat dataLength) {
                            picDraft.attachDataSize = dataLength;//kb
                            [weakSelf handleImageEncodeWithFileName:fileName size:size localIdentifier:localIdentifier allPicCount:picCount isSuccessed:result];
                        }];
                    }
                });
            }
            else
            {
                //no need
            }
        }
    }
    if (draft.video != nil)
    {
        self.compressStartTime = [[NSDate date] timeIntervalSince1970];
        __weak typeof(self) weakSelf = self;
        NSString *localIdentifier = [draft.video.asset.localIdentifier copy];
        NSString *name = [NSString stringWithFormat:@"%@.%@", [LuuUtils md5Encode:localIdentifier], @"mp4"];
        NSString *fileName = [[AppContext getCachePath] stringByAppendingPathComponent:name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName] == YES)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LuuLogger share] log:[NSString stringWithFormat:@"video compress AVAssetExportSessionStatusCompleted localIdentifier = %@ fileName = %@", localIdentifier, fileName] tag:@"publish"];
                WLMediaCompressedObj *obj = [[WLMediaCompressedObj alloc] init];
                obj.fileName = fileName;
                [weakSelf.compressMap setObject:obj forKey:localIdentifier];
                
                NSData *videoData = [NSData dataWithContentsOfFile:fileName];
                self->_compressLength = videoData.length/1024;
                
                if ([weakSelf.delegate respondsToSelector:@selector(onMediaCompressor:completed:)])
                {
                    [weakSelf.delegate onMediaCompressor:weakSelf.draftId completed:weakSelf.compressMap];
                }
            });
        }
        else
        {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            [[PHImageManager defaultManager] requestExportSessionForVideo:draft.video.asset options:options exportPreset:AVAssetExportPresetMediumQuality  resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                NSLog(@"%lld",exportSession.estimatedOutputFileLength);
                [weakSelf videoEncoding:exportSession fileName:fileName localIdentifier:localIdentifier];
            }];
        }
    }
}

- (void)handleImageEncodeWithFileName:(NSString *)fileName size:(CGSize)size localIdentifier:(NSString *)localIdentifier allPicCount:(NSInteger)picCount isSuccessed:(BOOL)isSuccessed
{
    self.count++;
    if (isSuccessed == YES)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"image compress ok localIdentifier = %@", localIdentifier] tag:@"publish"];
        WLMediaCompressedObj *obj = [[WLMediaCompressedObj alloc] init];
        obj.fileName = fileName;
        obj.width = size.width;
        obj.height = size.height;
        [self.compressMap setObject:obj forKey:localIdentifier];
    }
    if (self.count == picCount)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"image compress ok compressMap count = %ld", (long)[self.compressMap count]] tag:@"publish"];
        if ([self.delegate respondsToSelector:@selector(onMediaCompressor:completed:)])
        {
            for (WLAttachmentDraft *picDraft in compressDraft.picDraftList) {
                _compressLength += picDraft.attachDataSize;
            }
            
            [self.delegate onMediaCompressor:self.draftId completed:self.compressMap];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onMediaCompressor:process:)])
        {
            CGFloat process = ((CGFloat)self.count / (CGFloat)picCount) * 100.f;
            [self.delegate onMediaCompressor:self.draftId process:process];
        }
    }
}

- (void)videoEncoding:(AVAssetExportSession *)session fileName:(NSString *)fileName localIdentifier:(NSString *)localIdentifier
{
    session.outputURL = [NSURL fileURLWithPath:fileName];
    session.shouldOptimizeForNetworkUse = YES;
    session.outputFileType = AVFileTypeMPEG4;
    
    [[LuuLogger share] log:@"video compress videoEncoding" tag:@"publish"];
    
    __weak typeof(self) weakSelf = self;
    [session exportAsynchronouslyWithCompletionHandler:^{
        [weakSelf handleVideoEncode:session fileName:fileName localIdentifier:localIdentifier];
    }];
}

- (void)handleVideoEncode:(AVAssetExportSession *)session fileName:(NSString *)fileName localIdentifier:(NSString *)localIdentifier
{
    if (session.status == AVAssetExportSessionStatusCompleted)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"video compress AVAssetExportSessionStatusCompleted localIdentifier = %@ fileName = %@", localIdentifier, fileName] tag:@"publish"];
        WLMediaCompressedObj *obj = [[WLMediaCompressedObj alloc] init];
        obj.fileName = fileName;
        [self.compressMap setObject:obj forKey:localIdentifier];
         self.compressEndTime = [[NSDate date] timeIntervalSince1970];
        
        NSData *videoData = [NSData dataWithContentsOfFile:fileName];
        _compressLength = videoData.length/1024;
        
        if ([self.delegate respondsToSelector:@selector(onMediaCompressor:completed:)])
        {
            [self.delegate onMediaCompressor:self.draftId completed:self.compressMap];
        }
        
      
        //NSLog(@"%lld",videoData.length/1024);
    }
    else if (session.status == AVAssetExportSessionStatusFailed)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"video compress AVAssetExportSessionStatusFailed localIdentifier = %@ fileName = %@", localIdentifier, fileName] tag:@"publish"];
      
        self.compressStartTime = 0;
        self.compressEndTime = 0;
        _compressLength = 0;
        
        if ([self.delegate respondsToSelector:@selector(onMediaCompressor:completed:)])
        {
            [self.delegate onMediaCompressor:self.draftId completed:self.compressMap];
        }
        
      
    }
    else
    {
        self.compressStartTime = 0;
        self.compressEndTime = 0;
        _compressLength = 0;
        
        if ([self.delegate respondsToSelector:@selector(onMediaCompressor:process:)])
        {
            [self.delegate onMediaCompressor:self.draftId process:session.progress];
        }
    }
}

@end
