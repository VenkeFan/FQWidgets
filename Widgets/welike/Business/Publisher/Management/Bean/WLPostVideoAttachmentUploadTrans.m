//
//  WLPostVideoAttachmentUploadTrans.m
//  welike
//
//  Created by 刘斌 on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostVideoAttachmentUploadTrans.h"
#import "WLImageHelper.h"
#import "WLUploadManager.h"

@interface WLPostVideoAttachmentUploadTrans () <WLUploadManagerDelegate>

@property (nonatomic, strong) WLAttachmentDraft *attachmentDraft;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *thumbFileName;
@property (nonatomic, copy) NSString *thumbObjectKey;
@property (nonatomic, assign) BOOL videoCompleted;
@property (nonatomic, assign) BOOL thumbCompleted;

- (void)doStart;

@end

@implementation WLPostVideoAttachmentUploadTrans

- (id)initWithDraft:(WLAttachmentDraft *)attachmentDraft fileName:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        self.attachmentDraft = attachmentDraft;
        self.fileName = fileName;
        self.videoCompleted = YES;
        self.thumbCompleted = YES;
    }
    return self;
}

- (void)start
{
    if (self.attachmentDraft.asset.mediaType != PHAssetMediaTypeVideo)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
            {
                [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
            }
        });
        return;
    }
    
    [[LuuLogger share] log:@"video trans start" tag:@"publish"];
    __weak typeof(self) weakSelf = self;
    NSString *thumbFileName = [NSString stringWithFormat:@"%@.jpg", [[AppContext getCachePath] stringByAppendingPathComponent:[LuuUtils md5Encode:[LuuUtils uuid]]]];
    CGSize thumbSize = CGSizeMake(self.attachmentDraft.asset.pixelWidth, self.attachmentDraft.asset.pixelHeight);
    [WLImageHelper imageFromAsset:self.attachmentDraft.asset size:thumbSize result:^(UIImage *image) {
        BOOL res = [image storeToJPEG:thumbFileName quality:0.5f];
        if (res == YES)
        {
            [[LuuLogger share] log:[NSString stringWithFormat:@"video trans start thumb get %@", thumbFileName] tag:@"publish"];
            weakSelf.thumbFileName = thumbFileName;
        }
        [weakSelf doStart];
    }];
}

- (void)doStart
{
    [[AppContext getInstance].uploadManager registerDelegate:self];
    if ([self.attachmentDraft.objectKey length] > 0)
    {
        NSString *objectKey = [[AppContext getInstance].uploadManager uploadWithObjectKey:self.attachmentDraft.objectKey objFileName:self.fileName objectType:nil];
        if (objectKey == nil)
        {
            [[AppContext getInstance].uploadManager unregister:self];
            [LuuUtils removeFile:self.fileName];
            [LuuUtils removeFile:self.thumbFileName];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
                {
                    [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
                }
            });
            return;
        }
        else
        {
            self.videoCompleted = NO;
        }
    }
    else
    {
        NSString *objectKey = [[AppContext getInstance].uploadManager uploadWithFileName:self.fileName objectType:UPLOAD_TYPE_VIDEO];
        if ([objectKey length] > 0)
        {
            self.attachmentDraft.objectKey = objectKey;
            self.videoCompleted = NO;
            [[LuuLogger share] log:[NSString stringWithFormat:@"video trans doStart video upload objectKey = %@", objectKey] tag:@"publish"];
        }
        else
        {
            [[AppContext getInstance].uploadManager unregister:self];
            [LuuUtils removeFile:self.fileName];
            [LuuUtils removeFile:self.thumbFileName];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
                {
                    [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
                }
            });
            return;
        }
    }
    
    if ([self.thumbFileName length] > 0)
    {
        NSString *thumbObjectKey = [[AppContext getInstance].uploadManager uploadWithFileName:self.thumbFileName objectType:UPLOAD_TYPE_IMG];
        if ([thumbObjectKey length] > 0)
        {
            [[LuuLogger share] log:[NSString stringWithFormat:@"video trans doStart thumb upload objectKey = %@", thumbObjectKey] tag:@"publish"];
            self.thumbObjectKey = thumbObjectKey;
            self.thumbCompleted = NO;
        }
        else
        {
            self.thumbCompleted = YES;
            [LuuUtils removeFile:self.thumbFileName];
        }
    }
}

#pragma mark WLUploadManagerDelegate methods
- (void)onUploadingKey:(NSString *)objectKey completed:(NSString *)url
{
    if ([self.attachmentDraft.objectKey isEqualToString:objectKey] == YES)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"video trans onUploadingKey video objectKey = %@ completed url = %@", objectKey, url] tag:@"publish"];
        self.attachmentDraft.url = url;
        self.videoCompleted = YES;
    }
    else if ([self.thumbObjectKey isEqualToString:objectKey] == YES)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"video trans onUploadingKey thumb objectKey = %@ completed url = %@", objectKey, url] tag:@"publish"];
        self.attachmentDraft.thumbUrl = url;
        self.thumbCompleted = YES;
    }
    if (self.videoCompleted == YES && self.thumbCompleted == YES)
    {
        [[LuuLogger share] log:@"video trans video and thumb all completed" tag:@"publish"];
        NSLog(@"======video trans video and thumb all completed=====");
        NSLog(@"====thumb:%@",self.attachmentDraft.thumbUrl);
        [[AppContext getInstance].uploadManager unregister:self];
        [LuuUtils removeFile:self.fileName];
        [LuuUtils removeFile:self.thumbFileName];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentCompleted:)])
            {
                [weakSelf.delegate onPostAttachmentCompleted:weakSelf.attachmentDraft.asset.localIdentifier];
            }
        });
    }
}

- (void)onUploadingKey:(NSString *)objectKey failed:(NSInteger)errCode
{
    if ([self.attachmentDraft.objectKey isEqualToString:objectKey] == YES)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"video trans onUploadingKey video objectKey = %@ failed errCode = %ld", objectKey, (long)errCode] tag:@"publish"];
        [[AppContext getInstance].uploadManager unregister:self];
        [LuuUtils removeFile:self.fileName];
        [LuuUtils removeFile:self.thumbFileName];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
            {
                [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
            }
        });
    }
    else if ([self.thumbObjectKey isEqualToString:objectKey] == YES)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"video trans onUploadingKey thumb objectKey = %@ failed errCode = %ld", objectKey, (long)errCode] tag:@"publish"];
        self.thumbCompleted = YES;
    }
}

- (void)onUploadingKey:(NSString *)objectKey process:(CGFloat)process
{
    if ([self.attachmentDraft.objectKey isEqualToString:objectKey] == YES)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(self) weakSelf = self;
            if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachment:process:)])
            {
                [weakSelf.delegate onPostAttachment:weakSelf.attachmentDraft.asset.localIdentifier process:process];
            }
        });
    }
}

@end
