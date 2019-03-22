//
//  WLDraft.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "WLPostBase.h"

typedef NS_ENUM(NSInteger, WELIKE_DRAFT_TYPE)
{
    WELIKE_DRAFT_TYPE_POST = 0,
    WELIKE_DRAFT_TYPE_FORWARD_POST = 1,
    WELIKE_DRAFT_TYPE_FORWARD_COMMENT = 2,
    WELIKE_DRAFT_TYPE_COMMENT = 3,
    WELIKE_DRAFT_TYPE_REPLY = 4,
    WELIKE_DRAFT_TYPE_REPLY_OF_REPLY = 5
};

@interface WLAttachmentDraft : NSObject

@property (nonatomic, readonly) PHAsset *asset;
@property (nonatomic, copy) NSString *objectKey;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, assign) CGFloat tmpImgWidth;
@property (nonatomic, assign) CGFloat tmpImgHeight;
@property (nonatomic, assign) CGFloat attachDataSize; //压缩后才会有

- (id)initWithPHAsset:(PHAsset *)asset;

@end

@interface WLPollAttachmentDraft : NSObject

//@property (nonatomic, strong) WLAttachmentDraft *picDraft;
@property (nonatomic, copy) NSString *choiceName;
@property (nonatomic, assign) long long time;//单位s

- (id)initWithPHAsset:(PHAsset *)asset;

@end




@interface WLDraftBase : NSObject

@property (nonatomic, copy) NSString *draftId;
@property (nonatomic, assign) long long time;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) WLRichContent *content;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, assign) BOOL asRepost;
@property (nonatomic, strong) WLPostBase *parentPost; //原微博

@end

@interface WLCommentDraft : WLDraftBase

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong) WLRichContent *forwardContent;

@end

@interface WLReplyDraft : WLDraftBase

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong) WLRichContent *commentContent;

@end

@interface WLReplyOfReplyDraft : WLDraftBase

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *parentReplyId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong) WLRichContent *parentReplyContent;

@end

@interface WLPostDraftBase : WLDraftBase

@property (nonatomic, strong) RDLocation *location;

@end

@interface WLPostDraft : WLPostDraftBase

@property (nonatomic, strong) NSArray *picDraftList;
@property (nonatomic, strong) WLAttachmentDraft *video;
@property (nonatomic, strong) NSArray *pollDraftList; //投票选项

@end

@interface WLForwardDraft : WLPostDraftBase

@property (nonatomic, assign) BOOL asComment;

@end
