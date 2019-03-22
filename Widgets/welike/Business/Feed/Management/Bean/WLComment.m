//
//  WLComment.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLComment.h"
#import "WLRichItem.h"
#import "WLUser.h"
#import "NSDictionary+JSON.h"

#define KEY_WLCOMMENT_ID              @"id"
#define KEY_WLCOMMENT_COMMENT         @"comment"
#define KEY_WLCOMMENT_POST            @"post"
#define KEY_WLCOMMENT_POST_ID         @"id"
#define KEY_WLCOMMENT_TIME            @"created"
#define KEY_WLCOMMENT_CONTENT         @"content"
#define KEY_WLCOMMENT_LIKE            @"liked"
#define KEY_WLCOMMENT_DELETE          @"deleted"
#define KEY_WLCOMMENT_LIKE_COUNT      @"likedUsersCount"
#define KEY_WLCOMMENT_ATTACHMENTS     @"attachments"
#define KEY_WLCOMMENT_REPLIES_COUNT   @"repliesCount"
#define KEY_WLCOMMENT_USER            @"user"
#define KEY_WLCOMMENT_REPLIES         @"replies"

@implementation WLComment

+ (WLComment *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json != nil)
    {
        WLComment *comment = [[WLComment alloc ]init];
        comment.cid = [json stringForKey:KEY_WLCOMMENT_ID];
        id postObj = [json objectForKey:KEY_WLCOMMENT_POST];
        if ([postObj isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *postDic = (NSDictionary *)postObj;
            comment.pid = [postDic stringForKey:KEY_WLCOMMENT_POST_ID];
        }
        else
        {
            id parentComObj = [json objectForKey:KEY_WLCOMMENT_COMMENT];
            if ([parentComObj isKindOfClass:[NSDictionary class]] == YES)
            {
                postObj = [parentComObj objectForKey:KEY_WLCOMMENT_POST];
                if ([postObj isKindOfClass:[NSDictionary class]] == YES)
                {
                    NSDictionary *postDic = (NSDictionary *)postObj;
                    comment.pid = [postDic stringForKey:KEY_WLCOMMENT_POST_ID];
                }
            }
        }
        comment.time = [json longLongForKey:KEY_WLCOMMENT_TIME def:0];
        comment.childrenCount = [json integerForKey:KEY_WLCOMMENT_REPLIES_COUNT def:0];
        
        WLRichContent *rich = nil;
        NSString *content = [json stringForKey:KEY_WLCOMMENT_CONTENT];
        if ([content length] > 0)
        {
            rich = [[WLRichContent alloc] init];
            rich.text = content;
        }
        id richItemListObj = [json objectForKey:KEY_WLCOMMENT_ATTACHMENTS];
        if ([richItemListObj isKindOfClass:[NSArray class]] == YES)
        {
            if (rich == nil)
            {
                rich = [[WLRichContent alloc] init];
            }
            NSArray *richItemListJSON = (NSArray *)richItemListObj;
            NSMutableArray *richItemList = [NSMutableArray arrayWithCapacity:[richItemListJSON count]];
            for (NSInteger i = 0; i < [richItemListJSON count]; i++)
            {
                WLRichItem *richItem = [WLRichItem parseFromJSON:[richItemListJSON objectAtIndex:i]];
                [richItemList addObject:richItem];
            }
            rich.richItemList = [NSArray arrayWithArray:richItemList];
        }
        comment.content = rich;
        
        id userObj = [json objectForKey:KEY_WLCOMMENT_USER];
        if ([userObj isKindOfClass:[NSDictionary class]] == YES)
        {
            WLUser *user = [WLUser parseFromNetworkJSON:userObj];
            if (user != nil)
            {
                comment.uid = user.uid;
                comment.nickName = user.nickName;
                comment.head = user.headUrl;
                comment.following = user.following;
                comment.follower = user.follower;
                comment.vip = user.vip;
            }
        }
        comment.likeCount = [json integerForKey:KEY_WLCOMMENT_LIKE_COUNT def:0];
        comment.like = [json boolForKey:KEY_WLCOMMENT_LIKE def:NO];
        comment.deleted = [json boolForKey:KEY_WLCOMMENT_DELETE def:NO];
        
        id repliesObj = [json objectForKey:KEY_WLCOMMENT_REPLIES];
        if ([repliesObj isKindOfClass:[NSArray class]] == YES)
        {
            NSArray *repliesJSON = (NSArray *)repliesObj;
            NSMutableArray *replies = [NSMutableArray arrayWithCapacity:[repliesJSON count]];
            for (NSInteger i = 0; i < [repliesJSON count]; i++)
            {
                WLComment *reply = [WLComment parseFromNetworkJSON:[repliesJSON objectAtIndex:i]];
                if (reply != nil)
                {
                    [replies addObject:reply];
                }
            }
            comment.children = [NSArray arrayWithArray:replies];
        }
        return comment;
    }
    return nil;
}

@end
