//
//  WLPublishRichBuilder.m
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPublishRichBuilder.h"
#import "WLRichItem.h"
#import "WLRichTextHelper.h"

@implementation WLPublishRichBuilder


//对转发的post进行回复并转发-->转发的富文本需要拼接
+ (WLRichContent *)mergeForwardCommentRichText:(WLCommentDraft *)commentDraft
{
    if (!commentDraft.forwardContent)
    {
        return commentDraft.content;
    }
    
    NSInteger totleNum = [WLRichTextHelper caculateRichContentLength:commentDraft.forwardContent] + [WLRichTextHelper caculateRichContentLength:commentDraft.forwardContent] + 7;
    
    if (totleNum > 275 )
    {
        WLRichContent *richContent = [[WLRichContent alloc] init];
        richContent.text = [NSString stringWithFormat:@"reply@%@ %@",commentDraft.nickName,commentDraft.content.text];
        NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
        
        WLRichItem *mentionItem = [[WLRichItem alloc] init];
        mentionItem.type = WLRICH_TYPE_MENTION;
        mentionItem.source = [NSString stringWithFormat:@"@%@",commentDraft.nickName];
        mentionItem.rid = commentDraft.uid;
        mentionItem.index = 5;
        mentionItem.length = mentionItem.source.length;
        mentionItem.target = @"";
        mentionItem.display = mentionItem.source;
        mentionItem.title = @"";
        mentionItem.icon = @"";
        [richItemList addObject:mentionItem];
        
        NSInteger commentIndex = 5 + mentionItem.source.length + 1;
        
        for (WLRichItem *item in commentDraft.content.richItemList)
        {
            item.index = item.index + commentIndex;
        }
        [richItemList addObjectsFromArray:commentDraft.content.richItemList];
        
        richContent.richItemList = richItemList;
        
        richContent.summary = richContent.text;
        
        return richContent;
    }
    else
    {
        WLRichContent *richContent = [[WLRichContent alloc] init];
        richContent.text = [NSString stringWithFormat:@"reply@%@ %@//@%@:%@",commentDraft.nickName,commentDraft.content.text,commentDraft.nickName,commentDraft.forwardContent.text];
        NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
        
        WLRichItem *mentionItem = [[WLRichItem alloc] init];
        mentionItem.type = WLRICH_TYPE_MENTION;
        mentionItem.source = [NSString stringWithFormat:@"@%@",commentDraft.nickName];
        mentionItem.rid = commentDraft.uid;
        mentionItem.index = 5;
        mentionItem.length = mentionItem.source.length;
        mentionItem.target = @"";
        mentionItem.display = mentionItem.source;
        mentionItem.title = @"";
        mentionItem.icon = @"";
        [richItemList addObject:mentionItem];
        
        NSInteger commentIndex = 5 + mentionItem.source.length + 1;
        
        for (WLRichItem *item in commentDraft.content.richItemList)
        {
            item.index = item.index + commentIndex;
        }
        
        [richItemList addObjectsFromArray:commentDraft.content.richItemList];
        
        WLRichItem *secondeMentionItem = [[WLRichItem alloc] init];
        secondeMentionItem.type = WLRICH_TYPE_MENTION;
        secondeMentionItem.source = [NSString stringWithFormat:@"@%@",commentDraft.nickName];
        secondeMentionItem.rid = commentDraft.uid;
        secondeMentionItem.index = commentIndex + commentDraft.content.text.length + 2;
        secondeMentionItem.length = secondeMentionItem.source.length;
        secondeMentionItem.target = @"";
        secondeMentionItem.display = secondeMentionItem.source;
        secondeMentionItem.title = @"";
        secondeMentionItem.icon = @"";
        [richItemList addObject:secondeMentionItem];
        
        NSInteger forwardIndex = commentIndex + commentDraft.content.text.length + 2 + secondeMentionItem.source.length + 1;
        
        for (WLRichItem *item in commentDraft.forwardContent.richItemList)
        {
            item.index = item.index + forwardIndex;
        }
        
        [richItemList addObjectsFromArray:commentDraft.forwardContent.richItemList];
        
        
        richContent.richItemList = richItemList;
        
        richContent.summary =  richContent.text;;
        
        return richContent;
    }
}

//对一级评论进行回复并转发
+ (WLRichContent *)mergeForwardReplyRichText:(WLReplyDraft *)relpyDraft
{
    NSInteger totleNum = [WLRichTextHelper caculateRichContentLength:relpyDraft.content] + [WLRichTextHelper caculateRichContentLength:relpyDraft.commentContent] + 7;
    
    if (totleNum > 275 )
    {
        WLRichContent *richContent = [[WLRichContent alloc] init];
        richContent.text = [NSString stringWithFormat:@"reply@%@ %@",relpyDraft.nickName,relpyDraft.content.text];
        NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
        
        WLRichItem *mentionItem = [[WLRichItem alloc] init];
        mentionItem.type = WLRICH_TYPE_MENTION;
        mentionItem.source = [NSString stringWithFormat:@"@%@",relpyDraft.nickName];
        mentionItem.rid = relpyDraft.uid;
        mentionItem.index = 5;
        mentionItem.length = mentionItem.source.length;
        mentionItem.target = @"";
        mentionItem.display = mentionItem.source;
        mentionItem.title = @"";
        mentionItem.icon = @"";
        [richItemList addObject:mentionItem];
        
        NSInteger commentIndex = 5 + mentionItem.source.length + 1;
        
        WLRichContent *replyContent = [relpyDraft.content copy];
        
        for (WLRichItem *item in replyContent.richItemList)
        {
            item.index = item.index + commentIndex;
        }
        
        [richItemList addObjectsFromArray:replyContent.richItemList];
        
     
        richContent.richItemList = richItemList;
        richContent.summary = richContent.text;
        return richContent;
    }
    else
    {
        WLRichContent *richContent = [[WLRichContent alloc] init];
        richContent.text = [NSString stringWithFormat:@"reply@%@ %@//@%@:%@",relpyDraft.nickName,relpyDraft.content.text,relpyDraft.nickName,relpyDraft.commentContent.text];
        NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
        
        WLRichItem *mentionItem = [[WLRichItem alloc] init];
        mentionItem.type = WLRICH_TYPE_MENTION;
        mentionItem.source = [NSString stringWithFormat:@"@%@",relpyDraft.nickName];
        mentionItem.rid = relpyDraft.uid;
        mentionItem.index = 5;
        mentionItem.length = mentionItem.source.length;
        mentionItem.target = @"";
        mentionItem.display = mentionItem.source;
        mentionItem.title = @"";
        mentionItem.icon = @"";
        [richItemList addObject:mentionItem];
        
        NSInteger commentIndex = 5 + mentionItem.source.length + 1;
        
        WLRichContent *replyContent = [relpyDraft.content copy];
        
        for (WLRichItem *item in replyContent.richItemList)
        {
            item.index = item.index + commentIndex;
        }
        
        [richItemList addObjectsFromArray:replyContent.richItemList];
        
        WLRichItem *secondeMentionItem = [[WLRichItem alloc] init];
        secondeMentionItem.type = WLRICH_TYPE_MENTION;
        secondeMentionItem.source = [NSString stringWithFormat:@"@%@",relpyDraft.nickName];
        secondeMentionItem.rid = relpyDraft.uid;
        secondeMentionItem.index = commentIndex + relpyDraft.content.text.length + 2;
        secondeMentionItem.length = secondeMentionItem.source.length;
        secondeMentionItem.target = @"";
        secondeMentionItem.display = secondeMentionItem.source;
        secondeMentionItem.title = @"";
        secondeMentionItem.icon = @"";
        [richItemList addObject:secondeMentionItem];
        
        NSInteger forwardIndex = commentIndex + relpyDraft.content.text.length + 2 + secondeMentionItem.source.length + 1;
        
        WLRichContent *beCommentedContent = [relpyDraft.commentContent copy];
        
        for (WLRichItem *item in beCommentedContent.richItemList)
        {
            item.index = item.index + forwardIndex;
        }
        
        [richItemList addObjectsFromArray:beCommentedContent.richItemList];
        richContent.richItemList = richItemList;
        richContent.summary = richContent.text;
        return richContent;
    }
}

//对二级评论进行回复并转发,仅转发的文字
+ (WLRichContent *)mergeForwardReplyOfReplyRichText:(WLReplyOfReplyDraft *)relpyOfReplyDraft
{
    NSInteger totleNum = [WLRichTextHelper caculateRichContentLength:relpyOfReplyDraft.content] + [WLRichTextHelper caculateRichContentLength:relpyOfReplyDraft.parentReplyContent] + 7;
    
    if (totleNum > 275)
    {
        WLRichContent *richContent = [[WLRichContent alloc] init];
        richContent.text = [NSString stringWithFormat:@"reply@%@ %@",relpyOfReplyDraft.nickName,relpyOfReplyDraft.content.text];
        NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
        
        WLRichItem *mentionItem = [[WLRichItem alloc] init];
        mentionItem.type = WLRICH_TYPE_MENTION;
        mentionItem.source = [NSString stringWithFormat:@"@%@",relpyOfReplyDraft.nickName];
        mentionItem.rid = relpyOfReplyDraft.uid;
        mentionItem.index = 5;
        mentionItem.length = mentionItem.source.length;
        mentionItem.target = @"";
        mentionItem.display = mentionItem.source;
        mentionItem.title = @"";
        mentionItem.icon = @"";
        [richItemList addObject:mentionItem];
        
        NSInteger commentIndex = 5 + mentionItem.source.length + 1;
        
        WLRichContent *copyContent = [relpyOfReplyDraft.content copy];
        
        for (WLRichItem *item in copyContent.richItemList)
        {
            item.index = item.index + commentIndex;
        }
        
        [richItemList addObjectsFromArray:copyContent.richItemList];
        
        richContent.richItemList = richItemList;
        richContent.summary = richContent.text;
        return richContent;
    }
    else
    {
        WLRichContent *richContent = [[WLRichContent alloc] init];
        richContent.text = [NSString stringWithFormat:@"reply@%@ %@//@%@:%@",relpyOfReplyDraft.nickName,relpyOfReplyDraft.content.text,relpyOfReplyDraft.nickName,relpyOfReplyDraft.parentReplyContent.text];
        NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
        
        WLRichItem *mentionItem = [[WLRichItem alloc] init];
        mentionItem.type = WLRICH_TYPE_MENTION;
        mentionItem.source = [NSString stringWithFormat:@"@%@",relpyOfReplyDraft.nickName];
        mentionItem.rid = relpyOfReplyDraft.uid;
        mentionItem.index = 5;
        mentionItem.length = mentionItem.source.length;
        mentionItem.target = @"";
        mentionItem.display = mentionItem.source;
        mentionItem.title = @"";
        mentionItem.icon = @"";
        [richItemList addObject:mentionItem];
        
        NSInteger commentIndex = 5 + mentionItem.source.length + 1;
        
        WLRichContent *copyContent = [relpyOfReplyDraft.content copy];
        
        for (WLRichItem *item in copyContent.richItemList)
        {
            item.index = item.index + commentIndex;
        }
        
        [richItemList addObjectsFromArray:copyContent.richItemList];
        
        WLRichItem *secondeMentionItem = [[WLRichItem alloc] init];
        secondeMentionItem.type = WLRICH_TYPE_MENTION;
        secondeMentionItem.source = [NSString stringWithFormat:@"@%@",relpyOfReplyDraft.nickName];
        secondeMentionItem.rid = relpyOfReplyDraft.uid;
        secondeMentionItem.index = commentIndex + relpyOfReplyDraft.content.text.length + 2;
        secondeMentionItem.length = secondeMentionItem.source.length;
        secondeMentionItem.target = @"";
        secondeMentionItem.display = secondeMentionItem.source;
        secondeMentionItem.title = @"";
        secondeMentionItem.icon = @"";
        [richItemList addObject:secondeMentionItem];
        
        NSInteger forwardIndex = commentIndex + relpyOfReplyDraft.content.text.length + 2 + secondeMentionItem.source.length + 1;
        
        WLRichContent *beCommentedContent = [relpyOfReplyDraft.parentReplyContent copy];
        
        for (WLRichItem *item in beCommentedContent.richItemList)
        {
            item.index = item.index + forwardIndex;
        }
        
        [richItemList addObjectsFromArray:beCommentedContent.richItemList];
        richContent.richItemList = richItemList;
        richContent.summary = richContent.text;
        return richContent;
    }
}

//对二级评论进行回复,仅回复的文字
+ (WLRichContent *)mergeReplyOfReplyRichText:(WLReplyOfReplyDraft *)relpyOfReplyDraft //回复回复
{
    WLRichContent *richContent = [[WLRichContent alloc] init];
    richContent.text = [NSString stringWithFormat:@"reply@%@ %@",relpyOfReplyDraft.nickName,relpyOfReplyDraft.content.text];
    NSMutableArray *richItemList = [[NSMutableArray alloc] initWithCapacity:0];
    
    WLRichItem *mentionItem = [[WLRichItem alloc] init];
    mentionItem.type = WLRICH_TYPE_MENTION;
    mentionItem.source = [NSString stringWithFormat:@"@%@",relpyOfReplyDraft.nickName];
    mentionItem.rid = relpyOfReplyDraft.uid;
    mentionItem.index = 5;
    mentionItem.length = mentionItem.source.length;
    mentionItem.target = @"";
    mentionItem.display = mentionItem.source;
    mentionItem.title = @"";
    mentionItem.icon = @"";
    [richItemList addObject:mentionItem];
    
    NSInteger commentIndex = 5 + mentionItem.source.length + 1;
    
    WLRichContent *copyContent = [relpyOfReplyDraft.content copy];
    
    for (WLRichItem *item in copyContent.richItemList)
    {
        item.index = item.index + commentIndex;
    }
    
    [richItemList addObjectsFromArray:copyContent.richItemList];
    richContent.richItemList = richItemList;
    richContent.summary = richContent.text;
    return richContent;
}

@end
