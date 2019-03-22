//
//  WLPublishModel.h
//  welike
//
//  Created by gyb on 2018/12/7.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLTrackerPostClickedFromSource) {
    WLTrackPlaceFrom_TabController      = 1,
    WLTrackPlaceFrom_listCell           = 2,
    WLTrackPlaceFrom_PostDetail         = 3,
    WLTrackPlaceFrom_CommentDetail      = 4,
    WLTrackPlaceFrom_Draft              = 5,
    WLTrackPlaceFrom_TopicDetail        = 6,
    WLTrackPlaceFrom_CommentEmojiBtn    = 7,
};

typedef NS_ENUM(NSInteger, WLTrackerPostClickedFromMain_Source) {
    WLTrackPlaceFrom_OtherPage      = 0,
    WLTrackPlaceFrom_home           = 1,
    WLTrackPlaceFrom_discover         = 2,
    WLTrackPlaceFrom_message      = 3,
    WLTrackPlaceFrom_me              = 4,
    WLTrackPlaceFrom_otherApp        = 5   //外部程序
};

typedef NS_ENUM(NSInteger, WLTrackerPublishPage_type) {
    WLTrackerPublishPage_Post               = 1,
    WLTrackerPublishPage_Comment               = 2,
    WLTrackerPublishPage_Repost               = 3,
    WLTrackerPublishPage_Reply               = 4,  //（包括replyComment和replyReply）
};

typedef NS_ENUM(NSInteger, WLTrackerPublishExit_type) {
    WLTrackerPublishExit_Send                = 1,
    WLTrackerPublishExit_draft               = 2,
    WLTrackerPublishExit_closeWithOutSave    = 3  //不保存草稿直接退出
};

typedef NS_ENUM(NSInteger, WLPoll_type) {
    WLPoll_type_no_image                = 0,
    WLPoll_type_image               = 1
};

typedef NS_ENUM(NSInteger, WLPoll_time) {
    WLPoll_time_1               = 1, //1天
    WLPoll_time_2               = 2, //3天
    WLPoll_time_3               = 3, //1周
    WLPoll_time_4               = 4, //1月
    WLPoll_time_5               = 5, //无限制
};

typedef NS_ENUM(NSInteger, WLTopic_source) {
    WLTopic_source_detail                       = 1, //话题落地页
    WLTopic_source_recommand_topic               = 2,
    WLTopic_source_searchbar_manal_input        = 3,
    WLTopic_source_searchbar_new                = 4
};

typedef NS_ENUM(NSInteger, WLRepost_type) {
    WLRepost_type_no_choose                 = 0, //不转发
    WLRepost_type_choose                    = 1,
};

typedef NS_ENUM(NSInteger, WLComment_type) {
    WLComment_type_no_choose                 = 0, //不评论
    WLComment_type_choose                    = 1,
};


@interface WLPublishModel : NSObject


@property (assign ,nonatomic) WLTrackerPostClickedFromSource source;
@property (assign ,nonatomic) WLTrackerPostClickedFromMain_Source main_Source;
@property (assign ,nonatomic) WLTrackerPublishPage_type page_type;
@property (assign ,nonatomic) WLTrackerPublishExit_type exit_state;
@property (assign ,nonatomic) NSInteger words_num;
@property (assign ,nonatomic) NSInteger web_link;

@property (assign ,nonatomic) NSInteger picture_num;
@property (assign ,nonatomic) NSInteger picture_size;
@property (assign ,nonatomic) NSInteger picture_upload_time;

@property (assign ,nonatomic) NSInteger video_num;
@property (assign ,nonatomic) NSInteger video_size;
@property (assign ,nonatomic) NSInteger video_convert_time;
@property (assign ,nonatomic) NSInteger video_upload_time;

@property (assign ,nonatomic) WLPoll_type poll_type;
@property (assign ,nonatomic) NSInteger poll_num;
@property (assign ,nonatomic) WLPoll_time poll_time;

@property (assign ,nonatomic) NSInteger emoji_num;
@property (assign ,nonatomic) NSInteger at_num;
@property (assign ,nonatomic) NSInteger topic_num;

@property (assign ,nonatomic) WLTopic_source topic_source;
@property (assign ,nonatomic) WLRepost_type also_repost;
@property (assign ,nonatomic) WLComment_type also_comment;

@property (copy ,nonatomic) NSString *post_id;
@property (copy ,nonatomic) NSString *repost_id;
@property (copy ,nonatomic) NSString *topic_id;
@property (copy ,nonatomic) NSString *community;

@property (strong ,nonatomic) NSArray *post_tags;
@property (copy ,nonatomic) NSString *post_la;

@end
