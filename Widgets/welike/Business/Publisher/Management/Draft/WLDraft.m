//
//  WLDraft.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDraft.h"

@interface WLAttachmentDraft ()

@property (nonatomic, strong) PHAsset *asset;

@end

@interface WLPollAttachmentDraft ()


@end

@implementation WLAttachmentDraft

- (id)initWithPHAsset:(PHAsset *)asset
{
    self = [super init];
    if (self)
    {
        self.asset = asset;
    }
    return self;
}

@end

@implementation WLPollAttachmentDraft

- (id)initWithPHAsset:(PHAsset *)asset
{
    self = [super init];
    if (self)
    {
        //self.picDraft = [[WLAttachmentDraft alloc] initWithPHAsset:asset];
    }
    return self;
}

@end

@implementation WLDraftBase

@end

@implementation WLCommentDraft

@end

@implementation WLReplyDraft

@end

@implementation WLReplyOfReplyDraft

@end

@implementation WLPostDraftBase

@end

@implementation WLPostDraft

@end

@implementation WLForwardDraft

@end
