//
//  WLPublishTask.m
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPublishTask.h"
#import "WLDraft.h"
#import "WLMediaCompressor.h"
#import "WLPostPicAttachmentUploadTrans.h"
#import "WLPostVideoAttachmentUploadTrans.h"
#import "WLDraftManager.h"
#import "WLCreatePostRequest.h"
#import "WLCreateForwardedPostRequest.h"
#import "WLCreateCommentRequest.h"
#import "WLCreateReplyRequest.h"
#import "WLCreateReplyToReplyRequest.h"
#import "WLAccountManager.h"
#import "WLPublishRichBuilder.h"
#import "WLPublishModel.h"

#define kWLPublishTaskCompressProcessPart           30.f
#define kWLPublishTaskUploadingProcessPart          70.f

@interface WLPublishTask () <WLMediaCompressorDelegate, WLPostAttachmentUploadTransDelegate>

@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, strong) WLDraftBase *draft;
@property (nonatomic, strong) WLMediaCompressor *compressor;
@property (nonatomic, strong) NSMutableDictionary *attachmentsPool;
@property (nonatomic, strong) NSMutableArray *reqAttachmentList;
@property (nonatomic, assign) NSInteger errCode;
@property (nonatomic, assign) CGFloat baseProgress;

- (void)next;
- (void)videoUploadEndingCheck;
- (void)imageUploadEndingCheck;
- (NSInteger)calcImageCompletedCount;
- (void)handleCompleted;
- (void)handleFailed:(NSInteger)errCode;

@end

@implementation WLPublishTask

- (id)initWithDraft:(WLDraftBase *)draft
{
    self = [super init];
    if (self)
    {
        self.taskId = [LuuUtils uuid];
        self.draft = draft;
        self.baseProgress = 0;
        _state = WELIKE_PUBLISH_TASK_STATE_IDLE;
    }
    return self;
}

#pragma mark WLPublishTask public methods
- (void)start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(onPublishTaskBegin:)])
        {
            [self.delegate onPublishTaskBegin:self.taskId];
        }
    });
    
    self.draft.show = NO;
  
    
    if (self.draft.type == WELIKE_DRAFT_TYPE_POST)
    {
        [[LuuLogger share] log:@"post task start" tag:@"publish"];
        BOOL uploadFinish = YES;
        WLPostDraft *postDraft = (WLPostDraft *)self.draft;
       
        if (postDraft.pollDraftList.count == 0)
        {
            [[AppContext getInstance].draftManager insertOrUpdate:self.draft];
        }
        
        if ([postDraft.picDraftList count] > 0)
        {
            for (NSInteger i = 0; i < [postDraft.picDraftList count]; i++)
            {
                WLAttachmentDraft *picDraft = [postDraft.picDraftList objectAtIndex:i];
                if (picDraft.url == nil || [picDraft.url length] == 0)
                {
                    uploadFinish = NO;
                    break;
                }
            }
        }
        
        if (postDraft.video != nil && (postDraft.video.url == nil || [postDraft.video.url length] == 0))
        {
            uploadFinish = NO;
        }
        if (uploadFinish == NO)
        {
            _state = WELIKE_PUBLISH_TASK_STATE_UPLOADING;
            _uploadStartTime = [[NSDate date] timeIntervalSince1970];
//            NSLog(@"1=======%ld",(long)_uploadStartTime);
            [self next];
        }
        else
        {
            //当有图或者有视频的时候
            if ([postDraft.picDraftList count] > 0)
            {
                self.baseProgress = 30;
                [self allFileHasBeenUpload];
            }
            else
            {
                _state = WELIKE_PUBLISH_TASK_STATE_SENDING;
                [self next];
            }
        }
        
    }
    else
    {
        [[AppContext getInstance].draftManager insertOrUpdate:self.draft];
        _state = WELIKE_PUBLISH_TASK_STATE_SENDING;
        [self next];
    }
}

#pragma mark WLMediaCompressorDelegate methods
- (void)onMediaCompressor:(NSString *)draftId process:(CGFloat)process
{
    //NSLog(@"压缩%f",process);
    CGFloat p = (process/ 100.f) * (kWLPublishTaskCompressProcessPart / 100.f);
    self.baseProgress = p * 100;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(onPublishTask:process:)])
        {
            [self.delegate onPublishTask:self.taskId process:p];
        }
    });
}

- (void)onMediaCompressor:(NSString *)draftId completed:(NSMutableDictionary *)compressMap
{
    [[LuuLogger share] log:@"post task compress completed and start uploading" tag:@"publish"];
 
    if (self.attachmentsPool == nil)
    {
        self.attachmentsPool = [NSMutableDictionary dictionary];
    }
    
    self.baseProgress = kWLPublishTaskCompressProcessPart;
    
    WLPostDraft *postDraft = (WLPostDraft *)self.draft;
    if ([postDraft.picDraftList count] > 0)
    {
        _publishModel.picture_size = self.compressor.compressLength;
        
        for (NSInteger i = 0; i < [postDraft.picDraftList count]; i++)
        {
            WLAttachmentDraft *picDraft = [postDraft.picDraftList objectAtIndex:i];
            WLMediaCompressedObj *obj = [compressMap objectForKey:picDraft.asset.localIdentifier];//8330713A-98BA-460C-A564-6365E8DA52D2/L0/001
            if ([obj.fileName length] > 0)
            {
                picDraft.tmpImgWidth = obj.width;
                picDraft.tmpImgHeight = obj.height;
                WLPostPicAttachmentUploadTrans *trans = [[WLPostPicAttachmentUploadTrans alloc] initWithDraft:picDraft fileName:obj.fileName];
                trans.delegate = self;
                [self.attachmentsPool setObject:trans forKey:picDraft.asset.localIdentifier];
                [trans start];
            }
        }
    }
    
    if (postDraft.video != nil)
    {
        _publishModel.video_convert_time = self.compressor.compressEndTime - self.compressor.compressStartTime;
        _publishModel.video_size = self.compressor.compressLength;
        

        WLMediaCompressedObj *obj = [compressMap objectForKey:postDraft.video.asset.localIdentifier];
        if ([obj.fileName length] > 0)
        {
            WLPostVideoAttachmentUploadTrans *trans = [[WLPostVideoAttachmentUploadTrans alloc] initWithDraft:postDraft.video fileName:obj.fileName];
            trans.delegate = self;
            [self.attachmentsPool setObject:trans forKey:postDraft.video.asset.localIdentifier];
            [trans start];
        }
    }
    
    self.compressor.delegate = nil;
    self.compressor = nil;
}

#pragma mark WLPostAttachmentUploadTransDelegate methods
- (void)onPostAttachment:(NSString *)attachmentId process:(CGFloat)process
{
    id trans = [self.attachmentsPool objectForKey:attachmentId];
    if ([trans isKindOfClass:[WLPostVideoAttachmentUploadTrans class]] == YES)
    {
        // NSLog(@"上传进度%f===%f",self.baseProgress,process);
        WLPostDraft *postDraft = (WLPostDraft *)self.draft;
        if (postDraft.video != nil)
        {
            if ([attachmentId isEqualToString:postDraft.video.asset.localIdentifier] == YES)
            {
                CGFloat p = self.baseProgress / 100.f + process * (kWLPublishTaskUploadingProcessPart / 100.f);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(onPublishTask:process:)])
                    {
                        [self.delegate onPublishTask:self.taskId process:p];
                        //NSLog(@"上传进度%f",p);
                    }
                });
            }
        }
    }
    else if ([trans isKindOfClass:[WLPostPicAttachmentUploadTrans class]] == YES)
    {
        WLPostDraft *postDraft = (WLPostDraft *)self.draft;
        if ([postDraft.picDraftList count] == 1)
        {
            WLAttachmentDraft *picDraft = [postDraft.picDraftList objectAtIndex:0];
            if ([attachmentId isEqualToString:picDraft.asset.localIdentifier] == YES)
            {
                CGFloat p = self.baseProgress / 100.f + process * (kWLPublishTaskUploadingProcessPart / 100.f);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(onPublishTask:process:)])
                    {
                        [self.delegate onPublishTask:self.taskId process:p];
                    }
                });
            }
        }
    }
}

- (void)onPostAttachmentCompleted:(NSString *)attachmentId
{
    id trans = [self.attachmentsPool objectForKey:attachmentId];
    if (trans == nil) return;
    if ([trans isKindOfClass:[WLPostPicAttachmentUploadTrans class]])
    {
        ((WLPostPicAttachmentUploadTrans *)trans).delegate = nil;
    }
    else if ([trans isKindOfClass:[WLPostVideoAttachmentUploadTrans class]])
    {
        ((WLPostVideoAttachmentUploadTrans *)trans).delegate = nil;
    }
    
    [[LuuLogger share] log:[NSString stringWithFormat:@"post task uploading completed attachmentId = %@", attachmentId] tag:@"publish"];
    
    [self.attachmentsPool removeObjectForKey:attachmentId];
    
    
    [self allFileHasBeenUpload];
//    WLPostDraft *postDraft = (WLPostDraft *)self.draft;
//
//    if (postDraft.pollDraftList.count == 0)
//    {
//       [[AppContext getInstance].draftManager insertOrUpdate:self.draft];
//    }
//
//    if (postDraft.video != nil)
//    {
//        if ([self.attachmentsPool count] == 0)
//        {
//            [self videoUploadEndingCheck];
//        }
//    }
//    else if ([postDraft.picDraftList count] > 0)
//    {
//        NSInteger allCount = [postDraft.picDraftList count];
//        NSInteger completedCount = [self calcImageCompletedCount];
//        CGFloat rate = (CGFloat)completedCount / (CGFloat)allCount;
//        CGFloat p = self.baseProgress/ 100.f + rate * (kWLPublishTaskUploadingProcessPart / 100.f);
//        if ([self.delegate respondsToSelector:@selector(onPublishTask:process:)])
//        {
//            NSLog(@"ceshi=====%f===%f",rate,p);
//            [self.delegate onPublishTask:self.taskId process:p];
//        }
//        if ([self.attachmentsPool count] == 0)
//        {
//            [self imageUploadEndingCheck];
//        }
//    }
}

//当图片已经上传完成或者刚上传完成时候,需要更新草稿箱数据和进度
-(void)allFileHasBeenUpload
{
    WLPostDraft *postDraft = (WLPostDraft *)self.draft;
    
    if (postDraft.pollDraftList.count == 0)
    {
        [[AppContext getInstance].draftManager insertOrUpdate:self.draft];
    }
    
    if (postDraft.video != nil)
    {
        if ([self.attachmentsPool count] == 0)
        {
            [self videoUploadEndingCheck];
        }
    }
    else if ([postDraft.picDraftList count] > 0)
    {
        NSInteger allCount = [postDraft.picDraftList count];
        NSInteger completedCount = [self calcImageCompletedCount];
        CGFloat rate = (CGFloat)completedCount / (CGFloat)allCount;
        CGFloat p = self.baseProgress/ 100.f + rate * (kWLPublishTaskUploadingProcessPart / 100.f);
        if ([self.delegate respondsToSelector:@selector(onPublishTask:process:)])
        {
            NSLog(@"ceshi=====%f===%f",rate,p);
            [self.delegate onPublishTask:self.taskId process:p];
        }
        if ([self.attachmentsPool count] == 0)
        {
            [self imageUploadEndingCheck];
        }
    }
}

- (void)onPostAttachmentFailed:(NSString *)attachmentId
{
    id trans = [self.attachmentsPool objectForKey:attachmentId];
    if (trans == nil) return;
    if ([trans isKindOfClass:[WLPostPicAttachmentUploadTrans class]])
    {
        ((WLPostPicAttachmentUploadTrans *)trans).delegate = nil;
    }
    else if ([trans isKindOfClass:[WLPostVideoAttachmentUploadTrans class]])
    {
        ((WLPostVideoAttachmentUploadTrans *)trans).delegate = nil;
    }
    
    [[LuuLogger share] log:[NSString stringWithFormat:@"post task uploading failed attachmentId = %@", attachmentId] tag:@"publish"];
    
    [self.attachmentsPool removeObjectForKey:attachmentId];
    if ([self.attachmentsPool count] == 0)
    {
        WLPostDraft *postDraft = (WLPostDraft *)self.draft;
        if (postDraft.video != nil)
        {
            [self videoUploadEndingCheck];
        }
        else if ([postDraft.picDraftList count] > 0)
        {
            [self imageUploadEndingCheck];
        }
    }
}

#pragma mark WLPublishTask private methods
- (void)next
{
    if (_state == WELIKE_PUBLISH_TASK_STATE_UPLOADING)
    {
        [[LuuLogger share] log:@"post task start uploading" tag:@"publish"];
        if (self.compressor == nil)
        {
            self.compressor = [[WLMediaCompressor alloc] init];
            self.compressor.delegate = self;
        }
        [self.compressor compress:(WLPostDraft *)self.draft];
    }
    else if (_state == WELIKE_PUBLISH_TASK_STATE_SENDING)
    {
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        __weak typeof(self) weakSelf = self;
        if (self.draft.type == WELIKE_DRAFT_TYPE_POST)
        {
            WLPostDraft *postDraft = (WLPostDraft *)self.draft;
            
            if (postDraft.pollDraftList.count > 0)
            {
                if (postDraft.picDraftList.count > 0) //有图
                {
                    //生成数据
                    WLCreatePostRequest *request = [[WLCreatePostRequest alloc] initCreatePostRequestWithUid:account.uid];
                    
                    [request createPostWithContent:postDraft.content location:postDraft.location attachments:self.reqAttachmentList successed:^(NSDictionary *dic) {
                        weakSelf.draft.pid = [dic objectForKey:@"id"];
                        //topic
                         weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:dic];
                        [weakSelf handleCompleted];
                    } error:^(NSInteger errorCode) {
                        [weakSelf handleFailed:errorCode];
                    }];
                }
                else //无图
                {
                    WLCreatePostRequest *request = [[WLCreatePostRequest alloc] initCreatePostRequestWithUid:account.uid];
                    [request createPostWithContent:postDraft.content location:postDraft.location attachments:postDraft.pollDraftList successed:^(NSDictionary *dic) {
                        weakSelf.draft.pid = [dic objectForKey:@"id"];
                        //topic
                         weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:dic];
                        [weakSelf handleCompleted];
                    } error:^(NSInteger errorCode) {
                        [weakSelf handleFailed:errorCode];
                    }];
                }
            }
            else
            {
                WLCreatePostRequest *request = [[WLCreatePostRequest alloc] initCreatePostRequestWithUid:account.uid];
                [request createPostWithContent:postDraft.content location:postDraft.location attachments:self.reqAttachmentList successed:^(NSDictionary *dic){
                    weakSelf.draft.pid = [dic objectForKey:@"id"];
                    //topic
                    weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:dic];
                    [weakSelf handleCompleted];
                } error:^(NSInteger errorCode) {
                    [weakSelf handleFailed:errorCode];
                }];
            }
        }
        else if (self.draft.type == WELIKE_DRAFT_TYPE_FORWARD_POST || self.draft.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
            WLForwardDraft *forwardDraft = (WLForwardDraft *)self.draft;
            NSString *commentContent = nil;
            if (forwardDraft.asComment == YES)
            {
                commentContent = forwardDraft.content.summary;
            }
            WLCreateForwardedPostRequest *request = [[WLCreateForwardedPostRequest alloc] initCreateForwardedPostRequestWithUid:account.uid];
            
            [request createForwardedPostWithContent:forwardDraft.content pid:forwardDraft.parentPost.pid commentContent:commentContent successed:^(NSDictionary *dic) {
                
                NSDictionary *forwardPostDic = [[dic objectForKey:@"post"] objectForKey:@"forwardPost"];
                self->_publishModel.post_la = [forwardPostDic objectForKey:@"language"];
                self->_publishModel.post_tags = [forwardPostDic objectForKey:@"tags"];
                weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:[dic objectForKey:@"comment"]];
                [weakSelf handleCompleted];
            } error:^(NSInteger errorCode) {
                 [weakSelf handleFailed:errorCode];
            }];
            
        }
        else if (self.draft.type == WELIKE_DRAFT_TYPE_COMMENT)
        {
            WLCommentDraft *commentDraft = (WLCommentDraft *)self.draft;
            WLRichContent *postContent = nil;
            if (commentDraft.content != nil)
            {
                if (commentDraft.asRepost == YES)
                {
                    postContent = [WLPublishRichBuilder mergeForwardCommentRichText:commentDraft];
                }
            }
            WLCreateCommentRequest *request = [[WLCreateCommentRequest alloc] initCreateCommentRequestWithUid:account.uid];
            [request createCommentWithPid:commentDraft.pid commentContent:commentDraft.content postContent:postContent successed:^(NSDictionary *dic) {
                NSDictionary *forwardPostDic = [[dic objectForKey:@"post"] objectForKey:@"forwardPost"];
                self->_publishModel.post_la = [forwardPostDic objectForKey:@"language"];
                self->_publishModel.post_tags = [forwardPostDic objectForKey:@"tags"];
                 weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:[dic objectForKey:@"comment"]];
                [weakSelf handleCompleted];
            } error:^(NSInteger errorCode) {
                [weakSelf handleFailed:errorCode];
            }];
        }
        else if (self.draft.type == WELIKE_DRAFT_TYPE_REPLY)
        {
            WLReplyDraft *replyDraft = (WLReplyDraft *)self.draft;
            WLCreateReplyRequest *request = [[WLCreateReplyRequest alloc] initCreateReplyRequestWithUid:account.uid];
            WLRichContent *forwardPostContent = nil;
            if (replyDraft.content != nil)
            {
                if (replyDraft.asRepost == YES)
                {
                    forwardPostContent = [WLPublishRichBuilder mergeForwardReplyRichText:replyDraft];
                }
            }
            [request createReplyWithComment:replyDraft.content cid:replyDraft.cid forwardPostContent:forwardPostContent forwardPid:replyDraft.pid successed:^(NSDictionary *dic){
                NSDictionary *forwardPostDic = [[dic objectForKey:@"post"] objectForKey:@"forwardPost"];
                self->_publishModel.post_la = [forwardPostDic objectForKey:@"language"];
                self->_publishModel.post_tags = [forwardPostDic objectForKey:@"tags"];
                 weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:[dic objectForKey:@"reply"]];
                [weakSelf handleCompleted];
            } error:^(NSInteger errorCode) {
                [weakSelf handleFailed:errorCode];
            }];
        }
        else if (self.draft.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
        {
            WLReplyOfReplyDraft *replyReplyDraft = (WLReplyOfReplyDraft *)self.draft;
            WLRichContent *comment = nil;
            WLRichContent *forwardPostContent = nil;
            if (replyReplyDraft.content != nil)
            {
                comment = [WLPublishRichBuilder mergeReplyOfReplyRichText:replyReplyDraft];
                if (replyReplyDraft.asRepost == YES)
                {
                    forwardPostContent = [WLPublishRichBuilder mergeForwardReplyOfReplyRichText:replyReplyDraft];
                }
            }
            WLCreateReplyToReplyRequest *request = [[WLCreateReplyToReplyRequest alloc] initCreateReplyToReplyRequestWithUid:account.uid];
            [request createReplyToReplyWithComment:comment replyId:replyReplyDraft.parentReplyId cid:replyReplyDraft.cid forwardPostContent:forwardPostContent forwardPid:replyReplyDraft.pid successed:^(NSDictionary *dic){
                NSDictionary *forwardPostDic = [[dic objectForKey:@"post"] objectForKey:@"forwardPost"];
                self->_publishModel.post_la = [forwardPostDic objectForKey:@"language"];
                self->_publishModel.post_tags = [forwardPostDic objectForKey:@"tags"];
                 weakSelf.publishModel.topic_id =  [weakSelf handleTopicStr:[dic objectForKey:@"reply"]];
                [weakSelf handleCompleted];
            } error:^(NSInteger errorCode) {
                [weakSelf handleFailed:errorCode];
            }];
        }
    }
    else if (_state == WELIKE_PUBLISH_TASK_STATE_DONE)
    {
        [[AppContext getInstance].draftManager deleteDraftWithId:self.draft.draftId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(onPublishTaskCompleted:)])
            {
                [self.delegate onPublishTaskCompleted:self.taskId];
            }
        });
    }
    else if (_state == WELIKE_PUBLISH_TASK_STATE_FAILED)
    {
        WLPostDraft *postDraft = (WLPostDraft *)self.draft;
        if (postDraft.pollDraftList.count > 0)
        {
            self.draft.show = NO;
        }
        else
        {
            self.draft.show = YES;
            [[AppContext getInstance].draftManager resetUncompletedDraft:self.draft];
            [[AppContext getInstance].draftManager insertOrUpdate:self.draft];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onPublishTask:failed:)])
                {
                    [self.delegate onPublishTask:self.taskId failed:self.errCode];
                }
            });
        }
    }
}

- (void)videoUploadEndingCheck
{
    WLPostDraft *postDraft = (WLPostDraft *)self.draft;//video-2FB884ACE1914AFE9218E8C895BAAC7B
    WLAttachmentDraft *video = postDraft.video;
    if (self.reqAttachmentList == nil)
    {
        self.reqAttachmentList = [NSMutableArray array];
    }
    [self.reqAttachmentList removeAllObjects];
    if ([video.url length] > 0)
    {
        [[LuuLogger share] log:@"post task video ending check ok sending" tag:@"publish"];
        WLRequestPostAttachment *v = [[WLRequestPostAttachment alloc] init];
        v.attId = video.asset.localIdentifier;
        v.type = ATTACHMENT_VIDEO_TYPE;
        v.url = video.url;
        v.width = video.asset.pixelWidth;
        v.height = video.asset.pixelHeight;
        [self.reqAttachmentList addObject:v];
        NSLog(@"=======最后一步缩略图%@",video.thumbUrl);
        if ([video.thumbUrl length] > 0)
        {
            WLRequestPostAttachment *v2 = [[WLRequestPostAttachment alloc] init];
            v2.attId = [LuuUtils uuid];
            v2.targetAttId = video.asset.localIdentifier;
            v2.type = ADDITION_THUMB_TYPE;
            v2.url = video.thumbUrl;
            v2.width = video.asset.pixelWidth;
            v2.height = video.asset.pixelHeight;
            [self.reqAttachmentList addObject:v2];
        }
        _state = WELIKE_PUBLISH_TASK_STATE_SENDING;
        _uploadEndTime = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"video=====上传时间:%ld秒",_uploadEndTime - _uploadStartTime);
        _publishModel.video_upload_time = _uploadEndTime - _uploadStartTime;

        [self next];
    }
    else
    {
        [[LuuLogger share] log:@"post task video ending check failed" tag:@"publish"];
        [self handleFailed:ERROR_NETWORK_UPLOAD_FAILED];
    }
}

- (void)imageUploadEndingCheck
{
    WLPostDraft *postDraft = (WLPostDraft *)self.draft;
    NSInteger allCount = [postDraft.picDraftList count];
    NSInteger pollOptionCount = [postDraft.pollDraftList count];
    NSInteger completedCount = [self calcImageCompletedCount];
    if (completedCount == allCount)
    {
        [[LuuLogger share] log:@"post task image ending check ok sending" tag:@"publish"];
        if (self.reqAttachmentList == nil)
        {
            self.reqAttachmentList = [NSMutableArray array];
        }
        [self.reqAttachmentList removeAllObjects];
        for (NSInteger i = 0; i < [postDraft.picDraftList count]; i++)
        {
            if (pollOptionCount > 0)
            {
                WLAttachmentDraft *picAttachment = [postDraft.picDraftList objectAtIndex:i];
                WLPollAttachmentDraft *pollAttachment = [postDraft.pollDraftList objectAtIndex:i];
                WLRequestPostPollAttachment *p = [[WLRequestPostPollAttachment alloc] init];
                p.requestPostAttachment.attId = picAttachment.asset.localIdentifier;
                p.requestPostAttachment.type = ATTACHMENT_PIC_TYPE;
                p.requestPostAttachment.url = picAttachment.url;
                p.requestPostAttachment.width = picAttachment.tmpImgWidth;
                p.requestPostAttachment.height = picAttachment.tmpImgHeight;
                p.choiceName = pollAttachment.choiceName;
                p.time = pollAttachment.time;
                [self.reqAttachmentList addObject:p];
                _publishModel.picture_size += picAttachment.attachDataSize;
            }
            else
            {
                WLAttachmentDraft *picAttachment = [postDraft.picDraftList objectAtIndex:i];
                WLRequestPostAttachment *p = [[WLRequestPostAttachment alloc] init];
                p.attId = picAttachment.asset.localIdentifier;
                p.type = ATTACHMENT_PIC_TYPE;
                p.url = picAttachment.url;
                p.width = picAttachment.tmpImgWidth;
                p.height = picAttachment.tmpImgHeight;
                [self.reqAttachmentList addObject:p];
                _publishModel.picture_size += picAttachment.attachDataSize;
            }
        }
        _publishModel.picture_size =  _publishModel.picture_size;
        _state = WELIKE_PUBLISH_TASK_STATE_SENDING;
        _uploadEndTime = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"pic=====上传时间:%ld秒",_uploadEndTime - _uploadStartTime);
        _publishModel.picture_upload_time = _uploadEndTime - _uploadStartTime;
        
        [self next];
    }
    else
    {
         NSLog(@"=====上传时间失败");
        [[LuuLogger share] log:@"post task image ending check failed" tag:@"publish"];
        [self handleFailed:ERROR_NETWORK_UPLOAD_FAILED];
    }
}

- (NSInteger)calcImageCompletedCount
{
    NSInteger completedCount = 0;
    WLPostDraft *postDraft = (WLPostDraft *)self.draft;
    for (NSInteger i = 0; i < [postDraft.picDraftList count]; i++)
    {
        WLAttachmentDraft *picDraft = [postDraft.picDraftList objectAtIndex:i];
        if ([picDraft.url length] > 0)
        {
            completedCount++;
        }
    }
    return completedCount;
}

- (void)handleCompleted
{
    _state = WELIKE_PUBLISH_TASK_STATE_DONE;
    [self next];
    
  //  [[NSNotificationCenter defaultCenter] postNotificationName:WLNotificationUpdateDraft object:nil];
}

- (void)handleFailed:(NSInteger)errCode
{
    _state = WELIKE_PUBLISH_TASK_STATE_FAILED;
    self.errCode = errCode;
    [self next];
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:WLNotificationUpdateDraft object:nil];
}


-(NSString *)handleTopicStr:(NSDictionary *)dic
{
    NSArray *topicArray = [dic objectForKey:@"attachments"];
    
    NSMutableString *topicStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < topicArray.count; i++)
    {
        NSDictionary *info = topicArray[i];
        
        if ([[info objectForKey:@"type"] isEqualToString:@"TOPIC"])
        {
            [topicStr appendString:[NSString stringWithFormat:@"%@,", [info objectForKey:@"richId"]]];
        }
    }
    
    if (topicStr.length > 0)
    {
        [topicStr deleteCharactersInRange:NSMakeRange(topicStr.length - 1, 1)];
    }
    else
    {
        [topicStr appendString:@""];
    }
    return topicStr;
}


@end
