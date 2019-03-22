//
//  WLPostPicAttachmentUploadTrans.m
//  welike
//
//  Created by 刘斌 on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostPicAttachmentUploadTrans.h"
#import "WLUploadManager.h"

@interface WLPostPicAttachmentUploadTrans () <WLUploadManagerDelegate>

@property (nonatomic, strong) WLAttachmentDraft *attachmentDraft;
@property (nonatomic, copy) NSString *fileName;

@end

@implementation WLPostPicAttachmentUploadTrans

- (id)initWithDraft:(WLAttachmentDraft *)attachmentDraft fileName:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        self.attachmentDraft = attachmentDraft;
        self.fileName = fileName;
    }
    return self;
}

- (void)start
{
    if (self.attachmentDraft.asset.mediaType != PHAssetMediaTypeImage)
    {
        __weak typeof(self) weakSelf = self;
        [LuuUtils removeFile:self.fileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
            {
                [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
            }
        });
        return;
    }
    
    [[AppContext getInstance].uploadManager registerDelegate:self];
    if ([self.attachmentDraft.objectKey length] > 0)
    {
        NSString *objectKey = [[AppContext getInstance].uploadManager uploadWithObjectKey:self.attachmentDraft.objectKey objFileName:self.fileName objectType:nil];
        if (objectKey == nil)
        {
            [[AppContext getInstance].uploadManager unregister:self];
            [LuuUtils removeFile:self.fileName];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
                {
                    [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
                }
            });
        }
    }
    else
    {
        NSString *objectKey = [[AppContext getInstance].uploadManager uploadWithFileName:self.fileName objectType:UPLOAD_TYPE_IMG];
        if ([objectKey length] > 0)
        {
            self.attachmentDraft.objectKey = objectKey;
            [[LuuLogger share] log:[NSString stringWithFormat:@"pic trans start objectKey = %@", objectKey] tag:@"publish"];
        }
        else
        {
            [[AppContext getInstance].uploadManager unregister:self];
            [LuuUtils removeFile:self.fileName];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
                {
                    [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
                }
            });
        }
    }
}

#pragma mark WLUploadManagerDelegate methods
- (void)onUploadingKey:(NSString *)objectKey completed:(NSString *)url
{
    if ([self.attachmentDraft.objectKey isEqualToString:objectKey] == YES)
    {
        [[LuuLogger share] log:[NSString stringWithFormat:@"pic trans onUploadingKey objectKey = %@ completed url = %@", objectKey, url] tag:@"publish"];
        [[AppContext getInstance].uploadManager unregister:self];
        self.attachmentDraft.url = url;
        [LuuUtils removeFile:self.fileName];
        //在这里对上传的url进行本地记录
        //[WLUploadRecord addImageWithIdentifer:self.attachmentDraft.asset.localIdentifier imageUrl:url];
        
        [WLUploadRecord addImageWithIdentifer:self.attachmentDraft.asset.localIdentifier width:self.attachmentDraft.tmpImgWidth height:self.attachmentDraft.tmpImgHeight imageUrl:url];
        
//        NSArray *aa = [WLUploadRecord getAllRecord];
//          去
//        NSLog(@"====all url:%@",[aa description]);
        
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
        [[LuuLogger share] log:[NSString stringWithFormat:@"pic trans onUploadingKey objectKey = %@ failed errCode = %ld", objectKey, (long)errCode] tag:@"publish"];
        [[AppContext getInstance].uploadManager unregister:self];
        [LuuUtils removeFile:self.fileName];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onPostAttachmentFailed:)])
            {
                [weakSelf.delegate onPostAttachmentFailed:weakSelf.attachmentDraft.asset.localIdentifier];
            }
        });
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
