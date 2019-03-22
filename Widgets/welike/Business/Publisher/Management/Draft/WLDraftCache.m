//
//  WLDraftCache.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDraftCache.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLLinkPost.h"
#import "WLForwardPost.h"
#import "WLPicInfo.h"
#import "WLCommonDBManager.h"

#define DRAFT_COL_ID                            @"draft_id"
#define DRAFT_COL_TIME                          @"time"
#define DRAFT_COL_TYPE                          @"type"
#define DRAFT_COL_SHOW                          @"show"
#define DRAFT_COL_PID                           @"pid"
#define DRAFT_COL_CID                           @"cid"
#define DRAFT_COL_RID                           @"rid"
#define DRAFT_COL_TEXT                          @"text"
#define DRAFT_COL_SUMMARY                       @"summary"
#define DRAFT_COL_RICH                          @"rich"
#define DRAFT_COL_UID                           @"uid"
#define DRAFT_COL_NICKNAME                      @"nickname"
#define DRAFT_COL_P_TEXT                        @"p_text"
#define DRAFT_COL_P_SUMMARY                     @"p_summary"
#define DRAFT_COL_P_RICH                        @"p_rich"
#define DRAFT_COL_PLACE_ID                      @"place_id"
#define DRAFT_COL_PLACE                         @"place"
#define DRAFT_COL_LAT                           @"latitude"
#define DRAFT_COL_LON                           @"longitude"
#define DRAFT_COL_AS_COMMENT                    @"as_comment"
#define DRAFT_COL_AS_REPOST                     @"as_repost"
#define DRAFT_COL_PIC1                          @"pic1"
#define DRAFT_COL_PIC1_KEY                      @"pic1_key"
#define DRAFT_COL_PIC1_URL                      @"pic1_url"
#define DRAFT_COL_PIC2                          @"pic2"
#define DRAFT_COL_PIC2_KEY                      @"pic2_key"
#define DRAFT_COL_PIC2_URL                      @"pic2_url"
#define DRAFT_COL_PIC3                          @"pic3"
#define DRAFT_COL_PIC3_KEY                      @"pic3_key"
#define DRAFT_COL_PIC3_URL                      @"pic3_url"
#define DRAFT_COL_PIC4                          @"pic4"
#define DRAFT_COL_PIC4_KEY                      @"pic4_key"
#define DRAFT_COL_PIC4_URL                      @"pic4_url"
#define DRAFT_COL_PIC5                          @"pic5"
#define DRAFT_COL_PIC5_KEY                      @"pic5_key"
#define DRAFT_COL_PIC5_URL                      @"pic5_url"
#define DRAFT_COL_PIC6                          @"pic6"
#define DRAFT_COL_PIC6_KEY                      @"pic6_key"
#define DRAFT_COL_PIC6_URL                      @"pic6_url"
#define DRAFT_COL_PIC7                          @"pic7"
#define DRAFT_COL_PIC7_KEY                      @"pic7_key"
#define DRAFT_COL_PIC7_URL                      @"pic7_url"
#define DRAFT_COL_PIC8                          @"pic8"
#define DRAFT_COL_PIC8_KEY                      @"pic8_key"
#define DRAFT_COL_PIC8_URL                      @"pic8_url"
#define DRAFT_COL_PIC9                          @"pic9"
#define DRAFT_COL_PIC9_KEY                      @"pic9_key"
#define DRAFT_COL_PIC9_URL                      @"pic9_url"
#define DRAFT_COL_VIDEO                         @"video"
#define DRAFT_COL_VIDEO_KEY                     @"video_key"
#define DRAFT_COL_VIDEO_URL                     @"video_url"
#define DRAFT_COL_THUMB_URL                     @"thumb_url"
#define DRAFT_COL_POST                          @"post"

#define CREATE_DRAFT_TABLE_SQL @"CREATE TABLE IF NOT EXISTS draft (\
                                                                    %@ TEXT, \
                                                                    %@ INTEGER, \
                                                                    %@ INTEGER, \
                                                                    %@ INTEGER, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ INTEGER, \
                                                                    %@ INTEGER, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    %@ TEXT, \
                                                                    PRIMARY KEY(%@))"

#define UPDATE_DRAFT_SQL @"INSERT OR REPLACE INTO draft (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

@interface WLDraftCache ()

- (NSString *)convertRichListToJSON:(WLRichContent *)content;
- (NSArray *)convertJSONToRichList:(NSString *)rich;
- (BOOL)deleteWithIds:(NSArray *)ids db:(FMDatabase *)db;
- (WLDraftBase *)parseDraftFromDB:(FMResultSet *)set;

@end

@implementation WLDraftCache

#pragma mark WLDraftCache public methods
- (void)prepare
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] syncBlock:^{
        [db beginTransaction];
        
        NSString *sql = [NSString stringWithFormat:CREATE_DRAFT_TABLE_SQL,
                         DRAFT_COL_ID,
                         DRAFT_COL_TIME,
                         DRAFT_COL_TYPE,
                         DRAFT_COL_SHOW,
                         DRAFT_COL_PID,
                         DRAFT_COL_CID,
                         DRAFT_COL_RID,
                         DRAFT_COL_TEXT,
                         DRAFT_COL_SUMMARY,
                         DRAFT_COL_RICH,
                         DRAFT_COL_UID,
                         DRAFT_COL_NICKNAME,
                         DRAFT_COL_P_TEXT,
                         DRAFT_COL_P_SUMMARY,
                         DRAFT_COL_P_RICH,
                         DRAFT_COL_PLACE_ID,
                         DRAFT_COL_PLACE,
                         DRAFT_COL_LAT,
                         DRAFT_COL_LON,
                         DRAFT_COL_AS_COMMENT,
                         DRAFT_COL_AS_REPOST,
                         DRAFT_COL_PIC1,
                         DRAFT_COL_PIC1_KEY,
                         DRAFT_COL_PIC1_URL,
                         DRAFT_COL_PIC2,
                         DRAFT_COL_PIC2_KEY,
                         DRAFT_COL_PIC2_URL,
                         DRAFT_COL_PIC3,
                         DRAFT_COL_PIC3_KEY,
                         DRAFT_COL_PIC3_URL,
                         DRAFT_COL_PIC4,
                         DRAFT_COL_PIC4_KEY,
                         DRAFT_COL_PIC4_URL,
                         DRAFT_COL_PIC5,
                         DRAFT_COL_PIC5_KEY,
                         DRAFT_COL_PIC5_URL,
                         DRAFT_COL_PIC6,
                         DRAFT_COL_PIC6_KEY,
                         DRAFT_COL_PIC6_URL,
                         DRAFT_COL_PIC7,
                         DRAFT_COL_PIC7_KEY,
                         DRAFT_COL_PIC7_URL,
                         DRAFT_COL_PIC8,
                         DRAFT_COL_PIC8_KEY,
                         DRAFT_COL_PIC8_URL,
                         DRAFT_COL_PIC9,
                         DRAFT_COL_PIC9_KEY,
                         DRAFT_COL_PIC9_URL,
                         DRAFT_COL_VIDEO,
                         DRAFT_COL_VIDEO_KEY,
                         DRAFT_COL_VIDEO_URL,
                         DRAFT_COL_POST,
                         DRAFT_COL_THUMB_URL,
                         DRAFT_COL_ID];
        [db executeUpdate:sql];
        
        [db commit];
    }];
}

- (void)insertOrUpdate:(WLDraftBase *)draft
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *sql = [NSString stringWithFormat:UPDATE_DRAFT_SQL,
                         DRAFT_COL_ID,
                         DRAFT_COL_TIME,
                         DRAFT_COL_TYPE,
                         DRAFT_COL_SHOW,
                         DRAFT_COL_PID,
                         DRAFT_COL_CID,
                         DRAFT_COL_RID,
                         DRAFT_COL_TEXT,
                         DRAFT_COL_SUMMARY,
                         DRAFT_COL_RICH,
                         DRAFT_COL_UID,
                         DRAFT_COL_NICKNAME,
                         DRAFT_COL_P_TEXT,
                         DRAFT_COL_P_SUMMARY,
                         DRAFT_COL_P_RICH,
                         DRAFT_COL_PLACE_ID,
                         DRAFT_COL_PLACE,
                         DRAFT_COL_LAT,
                         DRAFT_COL_LON,
                         DRAFT_COL_AS_COMMENT,
                         DRAFT_COL_AS_REPOST,
                         DRAFT_COL_PIC1,
                         DRAFT_COL_PIC1_KEY,
                         DRAFT_COL_PIC1_URL,
                         DRAFT_COL_PIC2,
                         DRAFT_COL_PIC2_KEY,
                         DRAFT_COL_PIC2_URL,
                         DRAFT_COL_PIC3,
                         DRAFT_COL_PIC3_KEY,
                         DRAFT_COL_PIC3_URL,
                         DRAFT_COL_PIC4,
                         DRAFT_COL_PIC4_KEY,
                         DRAFT_COL_PIC4_URL,
                         DRAFT_COL_PIC5,
                         DRAFT_COL_PIC5_KEY,
                         DRAFT_COL_PIC5_URL,
                         DRAFT_COL_PIC6,
                         DRAFT_COL_PIC6_KEY,
                         DRAFT_COL_PIC6_URL,
                         DRAFT_COL_PIC7,
                         DRAFT_COL_PIC7_KEY,
                         DRAFT_COL_PIC7_URL,
                         DRAFT_COL_PIC8,
                         DRAFT_COL_PIC8_KEY,
                         DRAFT_COL_PIC8_URL,
                         DRAFT_COL_PIC9,
                         DRAFT_COL_PIC9_KEY,
                         DRAFT_COL_PIC9_URL,
                         DRAFT_COL_VIDEO,
                         DRAFT_COL_VIDEO_KEY,
                         DRAFT_COL_VIDEO_URL,
                         DRAFT_COL_THUMB_URL,
                         DRAFT_COL_POST];
        
        NSString *draftId = draft.draftId;
        NSNumber *time = [NSNumber numberWithLongLong:draft.time];
        NSNumber *type = [NSNumber numberWithInteger:draft.type];
        NSNumber *show = [NSNumber numberWithBool:draft.show];
        NSString *pid = nil;
        NSString *cid = nil;
        NSString *rid = nil;
        if ([draft isKindOfClass:[WLCommentDraft class]] == YES)
        {
            pid = ((WLCommentDraft *)draft).pid;
        }
        else if ([draft isKindOfClass:[WLReplyDraft class]] == YES)
        {
            pid = ((WLReplyDraft *)draft).pid;
            cid = ((WLReplyDraft *)draft).cid;
        }
        else if ([draft isKindOfClass:[WLReplyOfReplyDraft class]] == YES)
        {
            pid = ((WLReplyOfReplyDraft *)draft).pid;
            cid = ((WLReplyOfReplyDraft *)draft).cid;
            rid = ((WLReplyOfReplyDraft *)draft).parentReplyId;
        }
        NSString *text = draft.content.text;
        NSString *summary = draft.content.summary;
        NSString *rich = [self convertRichListToJSON:draft.content];
        NSString *uid = nil;
        NSString *nickName = nil;
        NSString *pText = nil;
        NSString *pSummary = nil;
        NSString *pRich = nil;
        NSNumber *asRepost = nil;
        if ([draft isKindOfClass:[WLCommentDraft class]] == YES)
        {
            WLCommentDraft *commentDraft = (WLCommentDraft *)draft;
            uid = commentDraft.uid;
            nickName = commentDraft.nickName;
            pText = commentDraft.forwardContent.text;
            pSummary = commentDraft.forwardContent.summary;
            pRich = [self convertRichListToJSON:commentDraft.forwardContent];
            asRepost = [NSNumber numberWithBool:commentDraft.asRepost];
        }
        else if ([draft isKindOfClass:[WLReplyDraft class]] == YES)
        {
            WLReplyDraft *replyDraft = (WLReplyDraft *)draft;
            uid = replyDraft.uid;
            nickName = replyDraft.nickName;
            pText = replyDraft.commentContent.text;
            pSummary = replyDraft.commentContent.summary;
            pRich = [self convertRichListToJSON:replyDraft.commentContent];
            asRepost = [NSNumber numberWithBool:replyDraft.asRepost];
        }
        else if ([draft isKindOfClass:[WLReplyOfReplyDraft class]] == YES)
        {
            WLReplyOfReplyDraft *replyOfReplyDraft = (WLReplyOfReplyDraft *)draft;
            uid = replyOfReplyDraft.uid;
            nickName = replyOfReplyDraft.nickName;
            pText = replyOfReplyDraft.parentReplyContent.text;
            pSummary = replyOfReplyDraft.parentReplyContent.summary;
            pRich = [self convertRichListToJSON:replyOfReplyDraft.parentReplyContent];
            asRepost = [NSNumber numberWithBool:replyOfReplyDraft.asRepost];
        }
        NSString *placeId = nil;
        NSString *place = nil;
        NSString *latitude = nil;
        NSString *longitude = nil;
        if ([draft isKindOfClass:[WLPostDraftBase class]] == YES)
        {
            RDLocation *location = ((WLPostDraftBase *)draft).location;
            placeId = location.placeId;
            place = location.place;
            latitude = [NSString stringWithFormat:@"%f", location.latitude];
            longitude = [NSString stringWithFormat:@"%f", location.longitude];
        }
        NSNumber *asComment = nil;
        if ([draft isKindOfClass:[WLForwardDraft class]] == YES)
        {
            asComment = [NSNumber numberWithBool:((WLForwardDraft *)draft).asComment];
        }
        NSString *pic1 = nil;
        NSString *pic1Key = nil;
        NSString *pic1Url = nil;
        NSString *pic2 = nil;
        NSString *pic2Key = nil;
        NSString *pic2Url = nil;
        NSString *pic3 = nil;
        NSString *pic3Key = nil;
        NSString *pic3Url = nil;
        NSString *pic4 = nil;
        NSString *pic4Key = nil;
        NSString *pic4Url = nil;
        NSString *pic5 = nil;
        NSString *pic5Key = nil;
        NSString *pic5Url = nil;
        NSString *pic6 = nil;
        NSString *pic6Key = nil;
        NSString *pic6Url = nil;
        NSString *pic7 = nil;
        NSString *pic7Key = nil;
        NSString *pic7Url = nil;
        NSString *pic8 = nil;
        NSString *pic8Key = nil;
        NSString *pic8Url = nil;
        NSString *pic9 = nil;
        NSString *pic9Key = nil;
        NSString *pic9Url = nil;
        NSString *video = nil;
        NSString *videoKey = nil;
        NSString *videoUrl = nil;
        NSString *thumbUrl = nil;
        if ([draft isKindOfClass:[WLPostDraft class]] == YES)
        {
            WLPostDraft *postDraft = (WLPostDraft *)draft;
            if ([postDraft.picDraftList count] > 0)
            {
                for (NSInteger i = 0; i < [postDraft.picDraftList count]; i++)
                {
                    WLAttachmentDraft *attachmentDraft = [postDraft.picDraftList objectAtIndex:i];
                    if (i == 0)
                    {
                        pic1 = attachmentDraft.asset.localIdentifier;
                        pic1Key = attachmentDraft.objectKey;
                        pic1Url = attachmentDraft.url;
                    }
                    else if (i == 1)
                    {
                        pic2 = attachmentDraft.asset.localIdentifier;
                        pic2Key = attachmentDraft.objectKey;
                        pic2Url = attachmentDraft.url;
                    }
                    else if (i == 2)
                    {
                        pic3 = attachmentDraft.asset.localIdentifier;
                        pic3Key = attachmentDraft.objectKey;
                        pic3Url = attachmentDraft.url;
                    }
                    else if (i == 3)
                    {
                        pic4 = attachmentDraft.asset.localIdentifier;
                        pic4Key = attachmentDraft.objectKey;
                        pic4Url = attachmentDraft.url;
                    }
                    else if (i == 4)
                    {
                        pic5 = attachmentDraft.asset.localIdentifier;
                        pic5Key = attachmentDraft.objectKey;
                        pic5Url = attachmentDraft.url;
                    }
                    else if (i == 5)
                    {
                        pic6 = attachmentDraft.asset.localIdentifier;
                        pic6Key = attachmentDraft.objectKey;
                        pic6Url = attachmentDraft.url;
                    }
                    else if (i == 6)
                    {
                        pic7 = attachmentDraft.asset.localIdentifier;
                        pic7Key = attachmentDraft.objectKey;
                        pic7Url = attachmentDraft.url;
                    }
                    else if (i == 7)
                    {
                        pic8 = attachmentDraft.asset.localIdentifier;
                        pic8Key = attachmentDraft.objectKey;
                        pic8Url = attachmentDraft.url;
                    }
                    else if (i == 8)
                    {
                        pic9 = attachmentDraft.asset.localIdentifier;
                        pic9Key = attachmentDraft.objectKey;
                        pic9Url = attachmentDraft.url;
                    }
                }
            }
            if (postDraft.video != nil)
            {
                video = postDraft.video.asset.localIdentifier;
                videoKey = postDraft.video.objectKey;
                videoUrl = postDraft.video.url;
                thumbUrl = postDraft.video.thumbUrl;
            }
        }
        
        NSString *parentPost = nil;
        if (draft.type == WELIKE_DRAFT_TYPE_FORWARD_POST ||
            draft.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
        {
            WLForwardDraft *forwardDraft = (WLForwardDraft *)draft;
            parentPost = [forwardDraft.parentPost encodeToJSONString];
        }
        
        [db executeUpdate:sql,
         draftId,
         time,
         type,
         show,
         pid,
         cid,
         rid,
         text,
         summary,
         rich,
         uid,
         nickName,
         pText,
         pSummary,
         pRich,
         placeId,
         place,
         latitude,
         longitude,
         asComment,
         asRepost,
         pic1,
         pic1Key,
         pic1Url,
         pic2,
         pic2Key,
         pic2Url,
         pic3,
         pic3Key,
         pic3Url,
         pic4,
         pic4Key,
         pic4Url,
         pic5,
         pic5Key,
         pic5Url,
         pic6,
         pic6Key,
         pic6Url,
         pic7,
         pic7Key,
         pic7Url,
         pic8,
         pic8Key,
         pic8Url,
         pic9,
         pic9Key,
         pic9Url,
         video,
         videoKey,
         videoUrl,
         thumbUrl,
         parentPost];
        
        [db commit];
    }];
}

- (void)deleteWithId:(NSString *)draftId
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM draft WHERE %@ = ?", DRAFT_COL_ID];
        [db executeUpdate:sql, draftId];
        
        [db commit];
    }];
}

- (void)deleteAll
{
    __weak typeof(self) weakSelf = self;
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM draft WHERE %@ = ?", DRAFT_COL_ID, DRAFT_COL_SHOW];
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithBool:YES]];
        NSMutableArray *draftIds = [NSMutableArray array];
        while ([rs next])
        {
            NSString *draftId = [rs stringForColumn:DRAFT_COL_ID];
            [draftIds addObject:draftId];
        }
        [rs close];
        [weakSelf deleteWithIds:draftIds db:db];
        
        [db commit];
    }];
}

- (void)reset
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM draft ORDER BY %@ DESC", DRAFT_COL_ID, DRAFT_COL_TIME];
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *draftIds = [NSMutableArray array];
        while ([rs next])
        {
            NSString *draftId = [rs stringForColumn:DRAFT_COL_ID];
            [draftIds addObject:draftId];
        }
        [rs close];
        
        NSMutableArray *deleteDraftIds = [NSMutableArray array];
        if ([draftIds count] > DRAFT_MAX_COUNT)
        {
            for (NSInteger i = ([draftIds count] - 1); i >= 0; i--)
            {
                if (i >= DRAFT_MAX_COUNT)
                {
                    [deleteDraftIds addObject:[draftIds objectAtIndex:i]];
                }
                else
                {
                    break;
                }
            }
            [draftIds removeObjectsInRange:NSMakeRange(DRAFT_MAX_COUNT, [draftIds count] - DRAFT_MAX_COUNT)];
        }
        if ([deleteDraftIds count] > 0)
        {
            [self deleteWithIds:deleteDraftIds db:db];
        }
        
        NSMutableArray *placeHolders = [NSMutableArray arrayWithCapacity:[draftIds count]];
        for (NSInteger i = 0; i < [draftIds count]; i++)
        {
            [placeHolders addObject:@"?"];
        }
        NSString *placeHolderString = [placeHolders componentsJoinedByString:@", "];
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE draft SET %@ = ? WHERE %@ IN (%@)", DRAFT_COL_SHOW, DRAFT_COL_ID, placeHolderString];
        NSMutableArray *params = [NSMutableArray arrayWithCapacity:([draftIds count] + 1)];
        [params addObject:[NSNumber numberWithBool:YES]];
        [params addObjectsFromArray:draftIds];
        [db executeUpdate:updateSql withArgumentsInArray:params];
        
        [db commit];
    }];
}

- (void)listAllShowable:(listAllShowableCompleted)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        NSMutableArray *drafts = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM draft WHERE %@ = ? ORDER BY %@ DESC LIMIT %d", DRAFT_COL_SHOW, DRAFT_COL_TIME, (int)DRAFT_MAX_COUNT];
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithBool:YES]];
        while ([rs next])
        {
            WLDraftBase *draft = [self parseDraftFromDB:rs];
            [drafts addObject:draft];
        }
        [rs close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(drafts);
            }
        });
    }];
}

- (void)countAllShowable:(countAllShowableCompleted)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        NSInteger count = 0;
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM draft WHERE %@ = ?", DRAFT_COL_SHOW];
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithBool:YES]];
        if ([rs next])
        {
            count = [rs intForColumnIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(count);
            }
        });
    }];
}

#pragma mark WLDraftCache private methods
- (NSString *)convertRichListToJSON:(WLRichContent *)content
{
    NSArray *richJSON = [content convertRichItemListToJSON];
    if ([richJSON count] > 0)
    {
        NSData *richData = [NSJSONSerialization dataWithJSONObject:richJSON options:NSJSONWritingPrettyPrinted error:nil];
        return [[NSString alloc] initWithData:richData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSArray *)convertJSONToRichList:(NSString *)rich
{
    if ([rich length] > 0)
    {
        NSArray *richJSON = [NSJSONSerialization JSONObjectWithData:[rich dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if ([richJSON count] > 0)
        {
            return [WLRichContent convertJSONToRichItemList:richJSON];
        }
    }
    return nil;
}

- (BOOL)deleteWithIds:(NSArray *)ids db:(FMDatabase *)db
{
    NSMutableArray *placeHolders = [NSMutableArray arrayWithCapacity:[ids count]];
    for (NSInteger i = 0; i < [ids count]; i++)
    {
        [placeHolders addObject:@"?"];
    }
    NSString *placeHolderString = [placeHolders componentsJoinedByString:@", "];
    NSString *delSql = [NSString stringWithFormat:@"DELETE FROM draft WHERE %@ IN (%@)", DRAFT_COL_ID, placeHolderString];
    return [db executeUpdate:delSql withArgumentsInArray:ids];
}

- (WLDraftBase *)parseDraftFromDB:(FMResultSet *)set
{
    WLDraftBase *draftBase = nil;
    WELIKE_DRAFT_TYPE type = [set intForColumn:DRAFT_COL_TYPE];
    if (type == WELIKE_DRAFT_TYPE_POST)
    {
        WLPostDraft *postDraft = [[WLPostDraft alloc] init];
        
        NSString *latitudeStr = [set stringForColumn:DRAFT_COL_LAT];
        NSString *longitudeStr = [set stringForColumn:DRAFT_COL_LON];
        NSString *place = [set stringForColumn:DRAFT_COL_PLACE];
        NSString *placeId = [set stringForColumn:DRAFT_COL_PLACE_ID];
        if ([placeId length] > 0 && [place length] > 0 && [longitudeStr length] > 0 && [latitudeStr length] > 0)
        {
            postDraft.location = [[RDLocation alloc] init];
            postDraft.location.placeId = placeId;
            postDraft.location.place = place;
            postDraft.location.longitude = [longitudeStr doubleValue];
            postDraft.location.latitude = [latitudeStr doubleValue];
        }
        
        NSMutableArray *picDraftList = nil;
        NSMutableArray *picAttachIds = [NSMutableArray array];
        NSString *pic1 = [set stringForColumn:DRAFT_COL_PIC1];
        if ([pic1 length] > 0)
        {
            [picAttachIds addObject:pic1];
        }
        NSString *pic2 = [set stringForColumn:DRAFT_COL_PIC2];
        if ([pic2 length] > 0)
        {
            [picAttachIds addObject:pic2];
        }
        NSString *pic3 = [set stringForColumn:DRAFT_COL_PIC3];
        if ([pic3 length] > 0)
        {
            [picAttachIds addObject:pic3];
        }
        NSString *pic4 = [set stringForColumn:DRAFT_COL_PIC4];
        if ([pic4 length] > 0)
        {
            [picAttachIds addObject:pic4];
        }
        NSString *pic5 = [set stringForColumn:DRAFT_COL_PIC5];
        if ([pic5 length] > 0)
        {
            [picAttachIds addObject:pic5];
        }
        NSString *pic6 = [set stringForColumn:DRAFT_COL_PIC6];
        if ([pic6 length] > 0)
        {
            [picAttachIds addObject:pic6];
        }
        NSString *pic7 = [set stringForColumn:DRAFT_COL_PIC7];
        if ([pic7 length] > 0)
        {
            [picAttachIds addObject:pic7];
        }
        NSString *pic8 = [set stringForColumn:DRAFT_COL_PIC8];
        if ([pic8 length] > 0)
        {
            [picAttachIds addObject:pic8];
        }
        NSString *pic9 = [set stringForColumn:DRAFT_COL_PIC9];
        if ([pic9 length] > 0)
        {
            [picAttachIds addObject:pic9];
        }
        if ([picAttachIds count] > 0)
        {
            if (picDraftList == nil)
            {
                picDraftList = [NSMutableArray array];
            }
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:picAttachIds options:nil];
            if ([assetsFetchResult count] > 0)
            {
                for (NSInteger i = 0; i < [assetsFetchResult count]; i++)
                {
                    PHAsset *asset = [assetsFetchResult objectAtIndex:i];
                    WLAttachmentDraft *pic = [[WLAttachmentDraft alloc] initWithPHAsset:asset];
                    if (i == 0)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC1_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC1_URL];
                    }
                    else if (i == 1)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC2_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC2_URL];
                    }
                    else if (i == 2)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC3_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC3_URL];
                    }
                    else if (i == 3)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC4_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC4_URL];
                    }
                    else if (i == 4)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC5_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC5_URL];
                    }
                    else if (i == 5)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC6_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC6_URL];
                    }
                    else if (i == 6)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC7_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC7_URL];
                    }
                    else if (i == 7)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC8_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC8_URL];
                    }
                    else if (i == 8)
                    {
                        pic.objectKey = [set stringForColumn:DRAFT_COL_PIC9_KEY];
                        pic.url = [set stringForColumn:DRAFT_COL_PIC9_URL];
                    }
                    [picDraftList addObject:pic];
                }
            }
            if ([picDraftList count] > 0)
            {
                postDraft.picDraftList = [NSArray arrayWithArray:picDraftList];
            }
        }
        
        NSString *video = [set stringForColumn:DRAFT_COL_VIDEO];
        NSString *videoKey = [set stringForColumn:DRAFT_COL_VIDEO_KEY];
        NSString *videoUrl = [set stringForColumn:DRAFT_COL_VIDEO_URL];
        NSString *thumbUrl = [set stringForColumn:DRAFT_COL_THUMB_URL];
        if ([video length] > 0)
        {
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[video] options:nil];
            if (assetsFetchResult != nil)
            {
                PHAsset *asset = [assetsFetchResult firstObject];
                WLAttachmentDraft *videoAtt = [[WLAttachmentDraft alloc] initWithPHAsset:asset];
                videoAtt.objectKey = videoKey;
                videoAtt.url = videoUrl;
                videoAtt.thumbUrl = thumbUrl;
                postDraft.video = videoAtt;
            }
        }
        draftBase = postDraft;
    }
    else if (type == WELIKE_DRAFT_TYPE_FORWARD_POST || type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
    {
        WLForwardDraft *forwardDraft = [[WLForwardDraft alloc] init];
        forwardDraft.asComment = [set boolForColumn:DRAFT_COL_AS_COMMENT];
        forwardDraft.parentPost = [WLPostBase decodeFromJSONString:[set stringForColumn:DRAFT_COL_POST]];
        
        NSString *latitudeStr = [set stringForColumn:DRAFT_COL_LAT];
        NSString *longitudeStr = [set stringForColumn:DRAFT_COL_LON];
        NSString *place = [set stringForColumn:DRAFT_COL_PLACE];
        NSString *placeId = [set stringForColumn:DRAFT_COL_PLACE_ID];
        if ([placeId length] > 0 && [place length] > 0 && [longitudeStr length] > 0 && [latitudeStr length] > 0)
        {
            forwardDraft.location = [[RDLocation alloc] init];
            forwardDraft.location.placeId = placeId;
            forwardDraft.location.place = place;
            forwardDraft.location.longitude = [longitudeStr doubleValue];
            forwardDraft.location.latitude = [latitudeStr doubleValue];
        }
        draftBase = forwardDraft;
    }
    else if (type == WELIKE_DRAFT_TYPE_COMMENT)
    {
        WLCommentDraft *commentDraft = [[WLCommentDraft alloc] init];
        commentDraft.pid = [set stringForColumn:DRAFT_COL_PID];
        commentDraft.uid = [set stringForColumn:DRAFT_COL_UID];
        commentDraft.nickName = [set stringForColumn:DRAFT_COL_NICKNAME];
        commentDraft.asRepost = [set boolForColumn:DRAFT_COL_AS_REPOST];
        NSString *text = [set stringForColumn:DRAFT_COL_P_TEXT];
        NSString *summary = [set stringForColumn:DRAFT_COL_P_SUMMARY];
        NSArray *rich = [self convertJSONToRichList:[set stringForColumn:DRAFT_COL_P_RICH]];
        if ([text length] > 0 || [rich count] > 0)
        {
            commentDraft.forwardContent = [[WLRichContent alloc] init];
            commentDraft.forwardContent.text = text;
            commentDraft.forwardContent.summary = summary;
            if ([rich count] > 0)
            {
                commentDraft.forwardContent.richItemList = [NSArray arrayWithArray:rich];
            }
        }
        draftBase = commentDraft;
    }
    else if (type == WELIKE_DRAFT_TYPE_REPLY)
    {
        WLReplyDraft *replyDraft = [[WLReplyDraft alloc] init];
        replyDraft.pid = [set stringForColumn:DRAFT_COL_PID];
        replyDraft.cid = [set stringForColumn:DRAFT_COL_CID];
        replyDraft.uid = [set stringForColumn:DRAFT_COL_UID];
        replyDraft.nickName = [set stringForColumn:DRAFT_COL_NICKNAME];
        replyDraft.asRepost = [set boolForColumn:DRAFT_COL_AS_REPOST];
        NSString *text = [set stringForColumn:DRAFT_COL_P_TEXT];
        NSString *summary = [set stringForColumn:DRAFT_COL_P_SUMMARY];
        NSArray *rich = [self convertJSONToRichList:[set stringForColumn:DRAFT_COL_P_RICH]];
        if ([text length] > 0 || [rich count] > 0)
        {
            replyDraft.commentContent = [[WLRichContent alloc] init];
            replyDraft.commentContent.text = text;
            replyDraft.commentContent.summary = summary;
            if ([rich count] > 0)
            {
                replyDraft.commentContent.richItemList = [NSArray arrayWithArray:rich];
            }
        }
        draftBase = replyDraft;
    }
    else if (type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
    {
        WLReplyOfReplyDraft *replyOfReplyDraft = [[WLReplyOfReplyDraft alloc] init];
        replyOfReplyDraft.pid = [set stringForColumn:DRAFT_COL_PID];
        replyOfReplyDraft.cid = [set stringForColumn:DRAFT_COL_CID];
        replyOfReplyDraft.parentReplyId = [set stringForColumn:DRAFT_COL_RID];
        replyOfReplyDraft.uid = [set stringForColumn:DRAFT_COL_UID];
        replyOfReplyDraft.nickName = [set stringForColumn:DRAFT_COL_NICKNAME];
        replyOfReplyDraft.asRepost = [set boolForColumn:DRAFT_COL_AS_REPOST];
        NSString *text = [set stringForColumn:DRAFT_COL_P_TEXT];
        NSString *summary = [set stringForColumn:DRAFT_COL_P_SUMMARY];
        NSArray *rich = [self convertJSONToRichList:[set stringForColumn:DRAFT_COL_P_RICH]];
        if ([text length] > 0 || [rich count] > 0)
        {
            replyOfReplyDraft.parentReplyContent = [[WLRichContent alloc] init];
            replyOfReplyDraft.parentReplyContent.text = text;
            replyOfReplyDraft.parentReplyContent.summary = summary;
            if ([rich count] > 0)
            {
                replyOfReplyDraft.parentReplyContent.richItemList = [NSArray arrayWithArray:rich];
            }
        }
        draftBase = replyOfReplyDraft;
    }
    
    if (draftBase != nil)
    {
        draftBase.draftId = [set stringForColumn:DRAFT_COL_ID];
        draftBase.time = [set longLongIntForColumn:DRAFT_COL_TIME];
        draftBase.type = type;
        draftBase.show = [set boolForColumn:DRAFT_COL_SHOW];
        NSString *text = [set stringForColumn:DRAFT_COL_TEXT];
        NSString *summary = [set stringForColumn:DRAFT_COL_SUMMARY];
        NSArray *rich = [self convertJSONToRichList:[set stringForColumn:DRAFT_COL_RICH]];
        if ([text length] > 0 || [rich count] > 0)
        {
            draftBase.content = [[WLRichContent alloc] init];
            draftBase.content.text = text;
            draftBase.content.summary = summary;
            if ([rich count] > 0)
            {
                draftBase.content.richItemList = [NSArray arrayWithArray:rich];
            }
        }
    }
    
    return draftBase;
}

@end
