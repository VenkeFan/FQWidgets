//
//  WLPostBase.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostBase.h"
#import "WLPicInfo.h"
#import "WLRichItem.h"
#import "WLForwardPost.h"
#import "WLTextPost.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLLinkPost.h"
#import "WLPollPost.h"
#import "NSDictionary+JSON.h"
#import <objc/runtime.h>
#import "WLArticalPostModel.h"
#import "WLUserBase.h"

#define KEY_WLPOST_ID                       @"id"
#define KEY_WLPOST_CONTENT                  @"content"
#define KEY_WLPOST_SUMMARY                  @"summary"
#define KEY_WLPOST_FROM                     @"source"
#define KEY_WLPOST_LIKE                     @"liked"
#define KEY_WLPOST_FORWARD_POST_COUNT       @"forwardedPostsCount"
#define KEY_WLPOST_LIKE_USER_COUNT          @"likedUsersCount"
#define KEY_WLPOST_CREATE_TIME              @"created"
#define KEY_WLPOST_COMMENT_COUNT            @"commentsCount"
#define KEY_WLPOST_READ_COUNT               @"readCount"
#define KEY_WLPOST_DELETE                   @"deleted"
#define KEY_WLPOST_EXP                      @"exp"
#define KEY_WLPOST_HOT                      @"hotPost"
#define KEY_WLPOST_IS_TOP                   @"isTop"
#define KEY_WLPOST_LOCATION                 @"location"
#define KEY_WLPOST_LOCATION_PLACE_ID        @"placeId"
#define KEY_WLPOST_LOCATION_PLACE_NAME      @"placeName"
#define KEY_WLPOST_LOCATION_LAT             @"lat"
#define KEY_WLPOST_LOCATION_LNG             @"lon"
#define KEY_WLPOST_FORWARD_POST             @"forwardPost"
#define KEY_WLPOST_ATTACHMENTS              @"attachments"
#define KEY_WLPOST_ATTACHMENTS_TYPE         @"type"
#define KEY_WLPOST_ATTACHMENTS_SOURCE       @"source"
#define KEY_WLPOST_ATTACHMENTS_ORIGINAL     @"original_image_url"

#define KEY_WLPOST_ATTACHMENTS_SITE         @"site"
#define KEY_WLPOST_ATTACHMENTS_VIDEO_COVER  @"icon"
#define KEY_WLPOST_ATTACHMENTS_PIC_WIDTH    @"image-width"
#define KEY_WLPOST_ATTACHMENTS_PIC_HEIGHT   @"image-height"
#define KEY_WLPOST_USER                     @"user"
#define KEY_WLPOST_ATTACHMENTS_VIDEO_WIDTH  @"video-width"
#define KEY_WLPOST_ATTACHMENTS_VIDEO_HEIGHT @"video-height"
#define KEY_WLPOST_LANGUAGE                 @"language"
#define KEY_WLPOST_TAGS                     @"tags"
#define KEY_WLPOST_ARTICLE                  @"article"

@interface WLPostBase ()

- (NSDictionary *)encodeToJSON;
+ (WLPostBase *)decodeFromJSON:(NSDictionary *)json;

@end

@implementation WLPostBase

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    if (self.type == WELIKE_POST_TYPE_PIC)
    {
        WLPicPost *picPost = (WLPicPost *)self;
        NSMutableArray *picInfoList = [NSMutableArray arrayWithCapacity:[picPost.picInfoList count]];
        for (NSInteger i = 0; i < [picPost.picInfoList count]; i++)
        {
            WLPicInfo *picInfo = [picPost.picInfoList objectAtIndex:i];
            NSMutableDictionary *picInfoDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [picInfoDic setObject:picInfo.picUrl forKey:@"picUrl"];
            [picInfoDic setObject:[NSNumber numberWithInteger:picInfo.width] forKey:@"width"];
            [picInfoDic setObject:[NSNumber numberWithInteger:picInfo.height] forKey:@"height"];
            [picInfoList addObject:picInfoDic];
        }
        [postDic setObject:picInfoList forKey:@"picInfoList"];
    }
    else if (self.type == WELIKE_POST_TYPE_VIDEO)
    {
        WLVideoPost *videoPost = (WLVideoPost *)self;
        if ([videoPost.videoUrl length] > 0)
        {
            [postDic setObject:videoPost.videoUrl forKey:@"videoUrl"];
        }
        if ([videoPost.coverUrl length] > 0)
        {
            [postDic setObject:videoPost.coverUrl forKey:@"coverUrl"];
        }
        if ([videoPost.videoSite length] > 0)
        {
            [postDic setObject:videoPost.videoSite forKey:@"videoSite"];
        }
    }
    else if (self.type == WELIKE_POST_TYPE_LINK)
    {
        WLLinkPost *linkPost = (WLLinkPost *)self;
        if ([linkPost.linkUrl length] > 0)
        {
            [postDic setObject:linkPost.linkUrl forKey:@"linkPost"];
        }
        if ([linkPost.linkTitle length] > 0)
        {
            [postDic setObject:linkPost.linkTitle forKey:@"linkTitle"];
        }
        if ([linkPost.linkText length] > 0)
        {
            [postDic setObject:linkPost.linkText forKey:@"linkText"];
        }
        if ([linkPost.linkThumbUrl length] > 0)
        {
            [postDic setObject:linkPost.linkThumbUrl forKey:@"linkThumbUrl"];
        }
    }
    else if (self.type == WELIKE_POST_TYPE_FORWARD)
    {
        WLForwardPost *forwardPost = (WLForwardPost *)self;
        [postDic setObject:[NSNumber numberWithBool:forwardPost.forwardDeleted] forKey:@"forwardDeleted"];
        if (forwardPost.rootPost != nil)
        {
            NSDictionary *rooPostDic = [forwardPost.rootPost encodeToJSON];
            [postDic setObject:rooPostDic forKey:@"rootPost"];
        }
    }
    [postDic setObject:self.pid forKey:@"pid"];
    [postDic setObject:self.uid forKey:@"uid"];
    [postDic setObject:[NSNumber numberWithInteger:self.type] forKey:@"type"];
    [postDic setObject:[NSNumber numberWithLongLong:self.time] forKey:@"time"];
    if ([self.headUrl length] > 0)
    {
        [postDic setObject:self.headUrl forKey:@"headUrl"];
    }
    if ([self.nickName length] > 0)
    {
        [postDic setObject:self.nickName forKey:@"nickName"];
    }
    [postDic setObject:[NSNumber numberWithBool:self.following] forKey:@"following"];
    [postDic setObject:[NSNumber numberWithBool:self.follower] forKey:@"follower"];
    if ([self.from length] > 0)
    {
        [postDic setObject:self.from forKey:@"from"];
    }
    if (self.location != nil)
    {
        NSMutableDictionary *locationDic = [NSMutableDictionary dictionary];
        if ([self.location.placeId length] > 0)
        {
            [locationDic setObject:self.location.placeId forKey:@"placeId"];
        }
        if ([self.location.place length] > 0)
        {
            [locationDic setObject:self.location.place forKey:@"place"];
        }
        [locationDic setObject:[NSNumber numberWithDouble:self.location.latitude] forKey:@"latitude"];
        [locationDic setObject:[NSNumber numberWithDouble:self.location.longitude] forKey:@"longitude"];
        [postDic setObject:locationDic forKey:@"location"];
    }
    if (self.language.length > 0) {
        [postDic setObject:self.language forKey:@"language"];
    }
    if (self.tags) {
        [postDic setObject:self.tags forKey:@"tags"];
    }
    if (self.sequenceId) {
        [postDic setObject:self.sequenceId forKey:@"sequenceId"];
    }
    
    [postDic setObject:[NSNumber numberWithLongLong:self.likeCount] forKey:@"likeCount"];
    [postDic setObject:[NSNumber numberWithBool:self.like] forKey:@"like"];
    [postDic setObject:[NSNumber numberWithLongLong:self.superLikeExp] forKey:@"superLikeExp"];
    [postDic setObject:[NSNumber numberWithBool:self.deleted] forKey:@"deleted"];
    [postDic setObject:[NSNumber numberWithBool:self.hot] forKey:@"hot"];
    [postDic setObject:[NSNumber numberWithBool:self.isTop] forKey:@"isTop"];
    [postDic setObject:[NSNumber numberWithInteger:self.commentCount] forKey:@"commentCount"];
    [postDic setObject:[NSNumber numberWithInteger:self.forwardCount] forKey:@"forwardCount"];
    [postDic setObject:[NSNumber numberWithInteger:self.readCount] forKey:@"readCount"];
    [postDic setObject:[NSNumber numberWithInteger:self.vip] forKey:@"vip"];
    
    if (self.richContent != nil)
    {
        NSMutableDictionary *richContentDic = [NSMutableDictionary dictionary];
        if ([self.richContent.text length] > 0)
        {
            [richContentDic setObject:self.richContent.text forKey:@"text"];
        }
        if ([self.richContent.summary length] > 0)
        {
            [richContentDic setObject:self.richContent.summary forKey:@"summary"];
        }
        if ([self.richContent.richItemList count] > 0)
        {
            [richContentDic setObject:[self.richContent convertRichItemListToJSON] forKey:@"richItemList"];
        }
        [postDic setObject:richContentDic forKey:@"richContent"];
    }
    return postDic;
}

- (NSString *)encodeToJSONString
{
    NSDictionary *jsonDic = [self encodeToJSON];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    if ([jsonData length] > 0)
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (WLPostBase *)decodeFromJSON:(NSDictionary *)json
{
    NSDictionary *postDic = json;
    WLPostBase *postBase = nil;
    WELIKE_POST_TYPE type = [[postDic objectForKey:@"type"] integerValue];
    if (type == WELIKE_POST_TYPE_PIC)
    {
        WLPicPost *picPost = [[WLPicPost alloc] init];
        NSArray *picInfoList = [postDic objectForKey:@"picInfoList"];
        if ([picInfoList count] > 0)
        {
            picPost.picInfoList = [NSMutableArray arrayWithCapacity:[picInfoList count]];
            for (NSInteger i = 0; i < [picInfoList count]; i++)
            {
                WLPicInfo *picInfo = [[WLPicInfo alloc] init];
                NSDictionary *picInfoDic = [picInfoList objectAtIndex:i];
                picInfo.picUrl = [picInfoDic objectForKey:@"picUrl"];
                picInfo.originalPicUrl = picInfo.picUrl;
                picInfo.width = [[picInfoDic objectForKey:@"width"] integerValue];
                picInfo.height = [[picInfoDic objectForKey:@"height"] integerValue];
                [picPost.picInfoList addObject:picInfo];
            }
        }
        postBase = picPost;
    }
    else if (type == WELIKE_POST_TYPE_VIDEO)
    {
        WLVideoPost *videoPost = [[WLVideoPost alloc] init];
        videoPost.videoUrl = [postDic objectForKey:@"videoUrl"];
        videoPost.coverUrl = [postDic objectForKey:@"coverUrl"];
        videoPost.videoSite = [postDic objectForKey:@"videoSite"];
        videoPost.width = [[postDic objectForKey:@"width"] integerValue];
        videoPost.height = [[postDic objectForKey:@"height"] integerValue];
        postBase = videoPost;
    }
    else if (type == WELIKE_POST_TYPE_LINK)
    {
        WLLinkPost *linkPost = [[WLLinkPost alloc] init];
        linkPost.linkUrl = [postDic objectForKey:@"linkUrl"];
        linkPost.linkTitle = [postDic objectForKey:@"linkTitle"];
        linkPost.linkText = [postDic objectForKey:@"linkText"];
        linkPost.linkThumbUrl = [postDic objectForKey:@"linkThumbUrl"];
        postBase = linkPost;
    }
    else if (type == WELIKE_POST_TYPE_FORWARD)
    {
        WLForwardPost *forwardPost = [[WLForwardPost alloc] init];
        NSDictionary *rootPost = [postDic objectForKey:@"rootPost"];
        if (rootPost != nil)
        {
            forwardPost.rootPost = [WLPostBase decodeFromJSON:rootPost];
        }
        forwardPost.forwardDeleted = [[postDic objectForKey:@"forwardDeleted"] boolValue];
        postBase = forwardPost;
    }
    else
    {
        WLTextPost *textPost = [[WLTextPost alloc] init];
        postBase = textPost;
    }
    
    postBase.pid = [postDic objectForKey:@"pid"];
    postBase.uid = [postDic objectForKey:@"uid"];
    postBase.type = type;
    postBase.time = [[postDic objectForKey:@"time"] longLongValue];
    postBase.headUrl = [postDic objectForKey:@"headUrl"];
    postBase.nickName = [postDic objectForKey:@"nickName"];
    postBase.following = [[postDic objectForKey:@"following"] boolValue];
    postBase.follower = [[postDic objectForKey:@"follower"] boolValue];
    postBase.from = [postDic objectForKey:@"from"];
    NSDictionary *locationDic = [postDic objectForKey:@"location"];
    if (locationDic != nil)
    {
        RDLocation *location = [[RDLocation alloc] init];
        location.place = [locationDic objectForKey:@"place"];
        location.placeId = [locationDic objectForKey:@"placeId"];
        location.latitude = [[locationDic objectForKey:@"latitude"] doubleValue];
        location.longitude = [[locationDic objectForKey:@"longitude"] doubleValue];
        postBase.location = location;
    }
    postBase.likeCount = [[postDic objectForKey:@"likeCount"] longLongValue];
    postBase.like = [[postDic objectForKey:@"like"] boolValue];
    postBase.superLikeExp = [[postDic objectForKey:@"superLikeExp"] longLongValue];
    postBase.deleted = [[postDic objectForKey:@"deleted"] boolValue];
    postBase.hot = [[postDic objectForKey:@"hot"] boolValue];
    postBase.isTop = [[postDic objectForKey:@"isTop"] boolValue];
    postBase.commentCount = [[postDic objectForKey:@"commentCount"] integerValue];
    postBase.forwardCount = [[postDic objectForKey:@"forwardCount"] integerValue];
    postBase.readCount = [[postDic objectForKey:@"readCount"] integerValue];
    postBase.vip = [[postDic objectForKey:@"vip"] integerValue];
    postBase.language = [postDic objectForKey:@"language"];
    postBase.tags = (NSArray *)[postDic objectForKey:@"tags"];
    postBase.sequenceId = [postDic objectForKey:@"sequenceId"];
    
    NSDictionary *richContentDic = [postDic objectForKey:@"richContent"];
    if (richContentDic != nil)
    {
        postBase.richContent = [[WLRichContent alloc] init];
        postBase.richContent.text = [richContentDic objectForKey:@"text"];
        postBase.richContent.summary = [richContentDic objectForKey:@"summary"];
        postBase.richContent.richItemList = [WLRichContent convertJSONToRichItemList:[richContentDic objectForKey:@"richItemList"]];
    }
    
    return postBase;
}

+ (WLPostBase *)decodeFromJSONString:(NSString *)string
{
    id jsonContent = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    if (jsonContent != nil && [jsonContent isKindOfClass:[NSDictionary class]] == YES)
    {
        NSDictionary *postDic = (NSDictionary *)jsonContent;
        return [WLPostBase decodeFromJSON:postDic];
    }
    return nil;
}

+ (WLPostBase *)parseFromNetworkJSON:(NSDictionary *)json
{
    WLPostBase *postBase = nil;
    if (json != nil)
    {
        NSMutableArray *picInfoList = nil;
        NSMutableArray *richItemList = nil;
        NSString *firstLink = nil;
        NSString *firstLinkTitle = nil;
        NSString *firstLinkIcon = nil;
        NSString *videoUrl = nil;
        NSString *videoCoverUrl = nil;
        NSString *videoSite = nil;
        NSInteger videoWidth = 0;
        NSInteger videoHeight = 0;
        
        id attachmentsObj = [json objectForKey:KEY_WLPOST_ATTACHMENTS];
        
        if ([attachmentsObj isKindOfClass:[NSArray class]] == YES)
        {
            // 有附件
            NSArray *attachmentsJSON = (NSArray *)attachmentsObj;
            for (NSInteger i = 0; i < [attachmentsJSON count]; i++)
            {
                NSDictionary *attDic = [attachmentsJSON objectAtIndex:i];
                NSString *type = [attDic stringForKey:KEY_WLPOST_ATTACHMENTS_TYPE];
                
                if ([type isEqualToString:ATTACHMENT_POLL_TYPE])
                {
                     //type为投票
                    NSDictionary *pollDic = [attDic objectForKey:@"poll"];
                    WLPollPost *pollModel = [WLPollPost modelWithDic:pollDic];
                    
                    postBase = pollModel;
                }
                else if ([type isEqualToString:ATTACHMENT_PIC_TYPE] == YES)
                {
                    // type为图片
                    WLPicInfo *picInfo = [[WLPicInfo alloc] init];
//                    picInfo.picUrl = [[attDic stringForKey:KEY_WLPOST_ATTACHMENTS_SOURCE] convertToHttps];
//                    picInfo.originalPicUrl = [[attDic stringForKey:KEY_WLPOST_ATTACHMENTS_ORIGINAL] convertToHttps];
                    if ([[attDic allKeys] containsObject:KEY_WLPOST_ATTACHMENTS_ORIGINAL])
                    {
                        picInfo.picUrl = [[attDic stringForKey:KEY_WLPOST_ATTACHMENTS_ORIGINAL] convertToHttps];
                        picInfo.originalPicUrl = picInfo.picUrl;
                    }
                    else
                    {
                        picInfo.picUrl = [[attDic stringForKey:KEY_WLPOST_ATTACHMENTS_SOURCE] convertToHttps];
                        picInfo.originalPicUrl = picInfo.picUrl;
                    }
                    
                    
                    picInfo.width = [attDic integerForKey:KEY_WLPOST_ATTACHMENTS_PIC_WIDTH def:0];
                    picInfo.height = [attDic integerForKey:KEY_WLPOST_ATTACHMENTS_PIC_HEIGHT def:0];
                    if (picInfoList == nil)
                    {
                        picInfoList = [NSMutableArray array];
                    }
                    [picInfoList addObject:picInfo];
                }
                else if ([type isEqualToString:ATTACHMENT_VIDEO_TYPE] == YES)
                {
                    // type为视频类型
                    videoUrl = [[attDic stringForKey:KEY_WLPOST_ATTACHMENTS_SOURCE] convertToHttps];
                    videoCoverUrl = [[attDic stringForKey:KEY_WLPOST_ATTACHMENTS_VIDEO_COVER] convertToHttps];
                    videoSite = [attDic stringForKey:KEY_WLPOST_ATTACHMENTS_SITE];
                    videoWidth = [attDic integerForKey:KEY_WLPOST_ATTACHMENTS_VIDEO_WIDTH def:0];
                    videoHeight = [attDic integerForKey:KEY_WLPOST_ATTACHMENTS_VIDEO_HEIGHT def:0];
                }
                else if (([type isEqualToString:WLRICH_TYPE_MENTION] == YES) ||
                         ([type isEqualToString:WLRICH_TYPE_TOPIC] == YES) ||
                         ([type isEqualToString:WLRICH_TYPE_LINK] == YES))
                {
                    WLRichItem *richItem = [WLRichItem parseFromJSON:attDic];
                    if ([type isEqualToString:WLRICH_TYPE_LINK] == YES)
                    {
                        firstLinkTitle = richItem.title;
                        firstLinkIcon = richItem.icon;
                        firstLink = richItem.target;
                    }
                    if (richItemList == nil)
                    {
                        richItemList = [NSMutableArray array];
                    }
                    [richItemList addObject:richItem];
                }
                else  if ([type isEqualToString:WLRICH_TYPE_ARTICLE] == YES)
                          {
                              WLRichItem *richItem = [WLRichItem parseFromJSON:attDic];
                              richItem.rid = [attDic objectForKey:@"id"];
                              [richItemList addObject:richItem];
                          }
                    
            }
        }
        
        id forwardObj = [json objectForKey:KEY_WLPOST_FORWARD_POST];
        if ([forwardObj isKindOfClass:[NSDictionary class]] == YES)
        {
            // 转发post，获取子post
            NSDictionary *forwardDic = (NSDictionary *)forwardObj;
            BOOL isDeleted = [forwardDic boolForKey:KEY_WLPOST_DELETE def:NO];
            if (isDeleted == NO)
            {
                WLPostBase *rootPost = [WLPostBase parseFromNetworkJSON:forwardDic];
                if (rootPost != nil)
                {
                    if (!rootPost.richContent)
                    {
                        WLForwardPost *forwardPost = [[WLForwardPost alloc] init];
                        forwardPost.forwardDeleted = YES;
                        postBase = forwardPost;
                    }
                    else
                    {
                        WLForwardPost *forwardPost = [[WLForwardPost alloc] init];
                        forwardPost.forwardDeleted = NO;
                        forwardPost.rootPost = rootPost;
                        postBase = forwardPost;
                    }
                }
            }
            else
            {
                WLForwardPost *forwardPost = [[WLForwardPost alloc] init];
                forwardPost.forwardDeleted = YES;
                postBase = forwardPost;
            }
        }
        
        
        if (postBase.type == WELIKE_POST_TYPE_POLL)
        {
            // do nothing
        }
        else if ([[json allKeys] containsObject:@"article"])
        {
            NSDictionary *articalDic = [json objectForKey:@"article"];
            
            WLArticalPostModel *articalPostModel = [WLArticalPostModel modelWithDic:articalDic];
            articalPostModel.type = WELIKE_POST_TYPE_ARTICAL;
            postBase = articalPostModel;
        }
        else if (picInfoList != nil)
        {
            if (postBase == nil)
            {
                postBase = [[WLPicPost alloc] init];
            }
            if ([postBase isKindOfClass:[WLPicPost class]] == YES)
            {
                WLPicPost *picPost = (WLPicPost *)postBase;
                picPost.picInfoList = picInfoList;
            }
        }
        else if ([videoUrl length] > 0)
        {
            if (postBase == nil)
            {
                postBase = [[WLVideoPost alloc] init];
            }
            if ([postBase isKindOfClass:[WLVideoPost class]] == YES)
            {
                WLVideoPost *videoPost = (WLVideoPost *)postBase;
                videoPost.videoUrl = videoUrl;
                videoPost.coverUrl = videoCoverUrl;
                videoPost.videoSite = videoSite;
                videoPost.width = videoWidth;
                videoPost.height = videoHeight;
            }
        }
        
        if (postBase == nil)
        {
            if ([firstLink length] > 0 && [firstLinkTitle length] > 0)
            {
                WLLinkPost *linkPost = [[WLLinkPost alloc] init];
                linkPost.linkUrl = firstLink;
                linkPost.linkTitle = firstLinkTitle;
                linkPost.linkThumbUrl = firstLinkIcon;
                postBase = linkPost;
            }
            else
            {
                postBase = [[WLTextPost alloc] init];
            }
        }
        
        id userObj = [json objectForKey:KEY_WLPOST_USER];
        if ([userObj isKindOfClass:[NSDictionary class]] == YES)
        {
            WLUser *user = [WLUser parseFromNetworkJSON:userObj];
            postBase.uid = user.uid;
            postBase.nickName = user.nickName;
            postBase.headUrl = user.headUrl;
            postBase.gender = user.gender;
            postBase.following = user.following;
            postBase.userCreateTime = user.createdTime;
            postBase.vip = user.vip;
            postBase.userHonors = user.honors;
        }
        WLRichContent *rich = nil;
        NSString *text = [json stringForKey:KEY_WLPOST_CONTENT];
        if ([text length] > 0)
        {
            rich = [[WLRichContent alloc] init];
            rich.text = text;
            rich.summary = [json stringForKey:KEY_WLPOST_SUMMARY];
        }
        if (richItemList != nil)
        {
            if (rich == nil)
            {
                rich = [[WLRichContent alloc] init];
            }
            rich.richItemList = [NSArray arrayWithArray:richItemList];
        }
        if (rich != nil)
        {
            postBase.richContent = rich;
        }
        
        postBase.hot = [json boolForKey:KEY_WLPOST_HOT def:NO];
        postBase.isTop = [json boolForKey:KEY_WLPOST_IS_TOP def:NO];
        postBase.pid = [json stringForKey:KEY_WLPOST_ID];
        postBase.like = [json boolForKey:KEY_WLPOST_LIKE def:NO];
        postBase.superLikeExp = [json longLongForKey:KEY_WLPOST_EXP def:0];
        postBase.deleted = [json boolForKey:KEY_WLPOST_DELETE def:NO];
        postBase.forwardCount = [json integerForKey:KEY_WLPOST_FORWARD_POST_COUNT def:0];
        postBase.likeCount = [json integerForKey:KEY_WLPOST_LIKE_USER_COUNT def:0];
        postBase.time = [json longLongForKey:KEY_WLPOST_CREATE_TIME def:0];
        postBase.commentCount = [json integerForKey:KEY_WLPOST_COMMENT_COUNT def:0];
        postBase.readCount = [json integerForKey:KEY_WLPOST_READ_COUNT def:0];
        postBase.from = [json stringForKey:KEY_WLPOST_FROM];
        postBase.language = [json stringForKey:KEY_WLPOST_LANGUAGE];
        postBase.tags = (NSArray *)[json objectForKey:KEY_WLPOST_TAGS];
        
        id locObj = [json objectForKey:KEY_WLPOST_LOCATION];
        if ([locObj isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *locDic = (NSDictionary *)locObj;
            RDLocation *location = [[RDLocation alloc] init];
            location.placeId = [locDic stringForKey:KEY_WLPOST_LOCATION_PLACE_ID];
            location.place = [locDic stringForKey:KEY_WLPOST_LOCATION_PLACE_NAME];
            location.latitude = [locDic doubleForKey:KEY_WLPOST_LOCATION_LAT def:0];
            location.longitude = [locDic doubleForKey:KEY_WLPOST_LOCATION_LNG def:0];
            postBase.location = location;
        }
    }
    return postBase;
}

@end


@implementation WLPostBase (WLTracker)

- (void)setTrackerSource:(WLTrackerFeedSource)trackerSource {
    objc_setAssociatedObject(self, @selector(trackerSource), @(trackerSource), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WLTrackerFeedSource)trackerSource {
    return (WLTrackerFeedSource)[objc_getAssociatedObject(self, @selector(trackerSource)) integerValue];
}

- (void)setTrackerSubType:(WLTrackerFeedSubType)trackerSubType {
    objc_setAssociatedObject(self, @selector(trackerSubType), trackerSubType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WLTrackerFeedSubType)trackerSubType {
    return (WLTrackerFeedSubType)objc_getAssociatedObject(self, @selector(trackerSubType));
}

@end
