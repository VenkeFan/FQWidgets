//
//  WLPublishTrack.m
//  welike
//
//  Created by gyb on 2018/12/6.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLPublishTrack.h"
#import "WLTracker.h"


#define kWLTrackPublishEventID                    @"5001018"

@implementation WLPublishTrack

//1.发布器界面展示
+(void)publishPageAppear:(WLTrackerPostClickedFromSource)source
             main_source:(WLTrackerPostClickedFromMain_Source)mainSource
               page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(1) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

//2.相机相册录像按钮点击
+(void)cameraBtnClicked:(WLTrackerPostClickedFromSource)source
            main_source:(WLTrackerPostClickedFromMain_Source)mainSource
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(2) forKey:@"action"];
    
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

//3.@按钮点击
+(void)mentionBtnClicked:(WLTrackerPostClickedFromSource)source
             main_source:(WLTrackerPostClickedFromMain_Source)mainSource
               page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(3) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//4.链接按钮点击
+(void)linkBtnClicked:(WLTrackerPostClickedFromSource)source
          main_source:(WLTrackerPostClickedFromMain_Source)mainSource
            page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(4) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
    
}


//5.location按钮点击
+(void)locationBtnClicked:(WLTrackerPostClickedFromSource)source
              main_source:(WLTrackerPostClickedFromMain_Source)mainSource
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(5) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//6.人搜索页展示
+(void)contactPageAppear:(WLTrackerPostClickedFromSource)source
             main_source:(WLTrackerPostClickedFromMain_Source)mainSource
               page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(6) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//7.@人有输入
+(void)contactPageInput:(WLTrackerPostClickedFromSource)source
            main_source:(WLTrackerPostClickedFromMain_Source)mainSource
              page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(7) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//8.@人Search online
+(void)contactPageSearchOnline:(WLTrackerPostClickedFromSource)source
                   main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                     page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(8) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//9.@人结果点击
+(void)contactPageSelectPersons:(WLTrackerPostClickedFromSource)source
                    main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                      page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(9) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//10.表情按钮点击
+(void)publishEmojiBtnClicked:(WLTrackerPostClickedFromSource)source
                  main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                    page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(10) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//11.链接按钮点击-链接输入框展示
+(void)publishLinkBtnDisplayed:(WLTrackerPostClickedFromSource)source
                 main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                   page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(11) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//12.链接输入框点击确认
+(void)publishLinkTInputViewClick:(WLTrackerPostClickedFromSource)source
                      main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                        page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(12) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//13.点击SEND按钮发布
+(void)publishSendBtnClicked:(WLPublishModel *)publishModel
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(13) forKey:@"action"];
    [eventInfo setObject:@(publishModel.source) forKey:@"source"];
    [eventInfo setObject:@(publishModel.main_Source) forKey:@"main_source"];
    [eventInfo setObject:@(publishModel.page_type) forKey:@"page_type"];
    
    [eventInfo setObject:@(publishModel.exit_state) forKey:@"exit_state"];
    [eventInfo setObject:@(publishModel.words_num) forKey:@"words_num"];
    [eventInfo setObject:@(publishModel.picture_num) forKey:@"picture_num"];
    [eventInfo setObject:@(publishModel.picture_size) forKey:@"picture_size"];
    [eventInfo setObject:@(publishModel.picture_upload_time) forKey:@"picture_upload_time"];
    [eventInfo setObject:@(publishModel.video_num) forKey:@"video_num"];
    [eventInfo setObject:@(publishModel.video_size) forKey:@"video_size"];
    [eventInfo setObject:@(publishModel.video_convert_time) forKey:@"video_convert_time"];
    [eventInfo setObject:@(publishModel.video_upload_time) forKey:@"video_upload_time"];
    [eventInfo setObject:@(publishModel.web_link) forKey:@"web_link"];
    [eventInfo setObject:@(publishModel.poll_type) forKey:@"poll_type"];
    [eventInfo setObject:@(publishModel.poll_num) forKey:@"poll_num"];
    [eventInfo setObject:@(publishModel.poll_time) forKey:@"poll_time"];
    [eventInfo setObject:@(publishModel.emoji_num) forKey:@"emoji_num"];
    [eventInfo setObject:@(publishModel.at_num) forKey:@"at_num"];
    [eventInfo setObject:@(publishModel.topic_num) forKey:@"topic_num"];
    [eventInfo setObject:@(publishModel.topic_source) forKey:@"topic_source"];
    [eventInfo setObject:@(publishModel.also_repost) forKey:@"also_repost"];
    [eventInfo setObject:@(publishModel.also_comment) forKey:@"also_comment"];
    [eventInfo setObject:publishModel.post_id forKey:@"post_id"];
    [eventInfo setObject:publishModel.repost_id forKey:@"repost_id"];
    [eventInfo setObject:publishModel.topic_id forKey:@"topic_id"];
    [eventInfo setObject:publishModel.community forKey:@"community"];
    [eventInfo setObject:publishModel.post_la forKey:@"post_la"];
    [eventInfo setObject:publishModel.post_tags forKey:@"post_tags"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//14.发布器界面退出
+(void)publishControllerClose:(WLPublishModel *)publishModel
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(14) forKey:@"action"];
    [eventInfo setObject:@(publishModel.source) forKey:@"source"];
    [eventInfo setObject:@(publishModel.main_Source) forKey:@"main_source"];
    [eventInfo setObject:@(publishModel.page_type) forKey:@"page_type"];
    
    [eventInfo setObject:@(publishModel.exit_state) forKey:@"exit_state"];
    [eventInfo setObject:@(publishModel.words_num) forKey:@"words_num"];
    [eventInfo setObject:@(publishModel.picture_num) forKey:@"picture_num"];
    [eventInfo setObject:@(publishModel.picture_size) forKey:@"picture_size"];
    [eventInfo setObject:@(publishModel.picture_upload_time) forKey:@"picture_upload_time"];
    [eventInfo setObject:@(publishModel.video_num) forKey:@"video_num"];
    [eventInfo setObject:@(publishModel.video_size) forKey:@"video_size"];
    [eventInfo setObject:@(publishModel.video_convert_time) forKey:@"video_convert_time"];
    [eventInfo setObject:@(publishModel.video_upload_time) forKey:@"video_upload_time"];
    [eventInfo setObject:@(publishModel.web_link) forKey:@"web_link"];
    [eventInfo setObject:@(publishModel.poll_type) forKey:@"poll_type"];
    [eventInfo setObject:@(publishModel.poll_num) forKey:@"poll_num"];
    [eventInfo setObject:@(publishModel.poll_time) forKey:@"poll_time"];
    [eventInfo setObject:@(publishModel.emoji_num) forKey:@"emoji_num"];
    [eventInfo setObject:@(publishModel.at_num) forKey:@"at_num"];
    [eventInfo setObject:@(publishModel.topic_num) forKey:@"topic_num"];
    [eventInfo setObject:@(publishModel.topic_source) forKey:@"topic_source"];
    [eventInfo setObject:@(publishModel.also_repost) forKey:@"also_repost"];
    [eventInfo setObject:@(publishModel.also_comment) forKey:@"also_comment"];
    [eventInfo setObject:publishModel.post_id forKey:@"post_id"];
    [eventInfo setObject:publishModel.repost_id forKey:@"repost_id"];
    [eventInfo setObject:publishModel.topic_id forKey:@"topic_id"];
    [eventInfo setObject:publishModel.community forKey:@"community"];
    [eventInfo setObject:publishModel.post_la forKey:@"post_la"];
    [eventInfo setObject:publishModel.post_tags forKey:@"post_tags"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//15.点击Send按钮发布并返回成功结果
+(void)publishSendBtnClickedAndSuccess:(WLPublishModel *)publishModel
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(15) forKey:@"action"];
    [eventInfo setObject:@(publishModel.source) forKey:@"source"];
    [eventInfo setObject:@(publishModel.main_Source) forKey:@"main_source"];
    [eventInfo setObject:@(publishModel.page_type) forKey:@"page_type"];
    
    [eventInfo setObject:@(publishModel.exit_state) forKey:@"exit_state"];
    [eventInfo setObject:@(publishModel.words_num) forKey:@"words_num"];
    [eventInfo setObject:@(publishModel.picture_num) forKey:@"picture_num"];
    [eventInfo setObject:@(publishModel.picture_size) forKey:@"picture_size"];
    [eventInfo setObject:@(publishModel.picture_upload_time) forKey:@"picture_upload_time"];
    [eventInfo setObject:@(publishModel.video_num) forKey:@"video_num"];
    [eventInfo setObject:@(publishModel.video_size) forKey:@"video_size"];
    [eventInfo setObject:@(publishModel.video_convert_time) forKey:@"video_convert_time"];
    [eventInfo setObject:@(publishModel.video_upload_time) forKey:@"video_upload_time"];
    [eventInfo setObject:@(publishModel.web_link) forKey:@"web_link"];
    [eventInfo setObject:@(publishModel.poll_type) forKey:@"poll_type"];
    [eventInfo setObject:@(publishModel.poll_num) forKey:@"poll_num"];
    [eventInfo setObject:@(publishModel.poll_time) forKey:@"poll_time"];
    [eventInfo setObject:@(publishModel.emoji_num) forKey:@"emoji_num"];
    [eventInfo setObject:@(publishModel.at_num) forKey:@"at_num"];
    [eventInfo setObject:@(publishModel.topic_num) forKey:@"topic_num"];
    [eventInfo setObject:@(publishModel.topic_source) forKey:@"topic_source"];
    [eventInfo setObject:@(publishModel.also_repost) forKey:@"also_repost"];
    [eventInfo setObject:@(publishModel.also_comment) forKey:@"also_comment"];
    [eventInfo setObject:publishModel.post_id forKey:@"post_id"];
    [eventInfo setObject:publishModel.repost_id forKey:@"repost_id"];
    [eventInfo setObject:publishModel.topic_id forKey:@"topic_id"];
    [eventInfo setObject:publishModel.community forKey:@"community"];
    [eventInfo setObject:publishModel.post_la forKey:@"post_la"];
    [eventInfo setObject:publishModel.post_tags forKey:@"post_tags"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//16.投票按钮点击
+(void)voteBtnClicked:(WLTrackerPostClickedFromSource)source
          main_source:(WLTrackerPostClickedFromMain_Source)mainSource
            page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(16) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//17.Add Hashtag点击  //TODO:目前还没有
+(void)addHashtagBtnClicked:(WLTrackerPostClickedFromSource)source
                main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                  page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(17) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//18.话题搜索页展示
+(void)searchTopicControllerAppear:(WLTrackerPostClickedFromSource)source
                       main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                         page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(18) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//19.话题有输入
+(void)inputTopicInSearchBar:(WLTrackerPostClickedFromSource)source
                 main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                   page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(19) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//20.话题点击,除了add topic下面那个话题
+(void)topicSelect:(WLTrackerPostClickedFromSource)source
      main_source:(WLTrackerPostClickedFromMain_Source)mainSource
        page_type:(WLTrackerPublishPage_type)pageType
     topic_source:(WLTopic_source)topic_source
         topic_id:(NSString *)topic_id
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(20) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    [eventInfo setObject:@(topic_source) forKey:@"topic_source"];
    [eventInfo setObject:topic_id forKey:@"topic_id"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//21.Add topic下侧的话题点击
+(void)addTopicClicked:(WLTrackerPostClickedFromSource)source
           main_source:(WLTrackerPostClickedFromMain_Source)mainSource
             page_type:(WLTrackerPublishPage_type)pageType
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(21) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"source"];
    [eventInfo setObject:@(mainSource) forKey:@"main_source"];
    [eventInfo setObject:@(pageType) forKey:@"page_type"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}


//22.点击Send按钮发布并返回失败结果
+(void)publishSendBtnClickedAndFail:(WLPublishModel *)publishModel
{
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    [eventInfo setObject:@(22) forKey:@"action"];
    [eventInfo setObject:@(publishModel.source) forKey:@"source"];
    [eventInfo setObject:@(publishModel.main_Source) forKey:@"main_source"];
    [eventInfo setObject:@(publishModel.page_type) forKey:@"page_type"];
    
    [eventInfo setObject:@(publishModel.exit_state) forKey:@"exit_state"];
    [eventInfo setObject:@(publishModel.words_num) forKey:@"words_num"];
    [eventInfo setObject:@(publishModel.picture_num) forKey:@"picture_num"];
    [eventInfo setObject:@(publishModel.picture_size) forKey:@"picture_size"];
    [eventInfo setObject:@(publishModel.picture_upload_time) forKey:@"picture_upload_time"];
    [eventInfo setObject:@(publishModel.video_num) forKey:@"video_num"];
    [eventInfo setObject:@(publishModel.video_size) forKey:@"video_size"];
    [eventInfo setObject:@(publishModel.video_convert_time) forKey:@"video_convert_time"];
    [eventInfo setObject:@(publishModel.video_upload_time) forKey:@"video_upload_time"];
    [eventInfo setObject:@(publishModel.web_link) forKey:@"web_link"];
    [eventInfo setObject:@(publishModel.poll_type) forKey:@"poll_type"];
    [eventInfo setObject:@(publishModel.poll_num) forKey:@"poll_num"];
    [eventInfo setObject:@(publishModel.poll_time) forKey:@"poll_time"];
    [eventInfo setObject:@(publishModel.emoji_num) forKey:@"emoji_num"];
    [eventInfo setObject:@(publishModel.at_num) forKey:@"at_num"];
    [eventInfo setObject:@(publishModel.topic_num) forKey:@"topic_num"];
    [eventInfo setObject:@(publishModel.topic_source) forKey:@"topic_source"];
    [eventInfo setObject:@(publishModel.also_repost) forKey:@"also_repost"];
    [eventInfo setObject:@(publishModel.also_comment) forKey:@"also_comment"];
    [eventInfo setObject:publishModel.post_id forKey:@"post_id"];
    [eventInfo setObject:publishModel.repost_id forKey:@"repost_id"];
    [eventInfo setObject:publishModel.topic_id forKey:@"topic_id"];
    [eventInfo setObject:publishModel.community forKey:@"community"];
    [eventInfo setObject:publishModel.post_la forKey:@"post_la"];
    [eventInfo setObject:publishModel.post_tags forKey:@"post_tags"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackPublishEventID
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}





@end
