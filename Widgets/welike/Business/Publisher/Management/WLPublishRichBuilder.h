//
//  WLPublishRichBuilder.h
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLRichContent.h"
#import "WLDraft.h"

@interface WLPublishRichBuilder : NSObject

+ (WLRichContent *)mergeForwardCommentRichText:(WLCommentDraft *)commentDraft;
+ (WLRichContent *)mergeForwardReplyRichText:(WLReplyDraft *)relpyDraft;
+ (WLRichContent *)mergeForwardReplyOfReplyRichText:(WLReplyOfReplyDraft *)relpyOfReplyDraft;
+ (WLRichContent *)mergeReplyOfReplyRichText:(WLReplyOfReplyDraft *)relpyOfReplyDraft;

@end
