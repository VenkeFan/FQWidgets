//
//  RDServiceGlobal.h
//  welike
//
//  Created by 刘斌 on 2018/4/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#ifndef RDServiceGlobal_h
#define RDServiceGlobal_h

#define __WELIKE_TEST_          1

#ifdef __WELIKE_TEST_
#define kDevHostName @""
#define kDevUploadHostName @""
#define kDevDownloadHostName @""
#define kDevTrackHostName @""
#define kDevLongConnectionAddress @""
#define kPreHostName @""
#define kPreUploadHostName @""
#define kPreDownloadHostName @""
#define kPreTrackHostName @""
#define kPreLongConnectionAddress @""
#define kPreAliBucket @""
#define kPreEndPoint  @""
#define kPreAliUploadHostName @""
#define kPreSts @""

#define kTestLongConnectionPort 8200
#else
#define kHostName @""
#define kUploadHostName @""
#define kDownloadHostName @""
#define kTrackHostName @""
#define kLongConnectionAddress @""
#define kAliBucket @""
#define kEndPoint  @""
#define kAliUploadHostName @""
#define kSts @""


#define kLongConnectionPort 8200
#endif


#define AppStroeUrl @"https://itunes.apple.com/cn/app/welike-local-trend-share/id1389918107?mt=8"


#define kDatabasePath @"database"

#define ERROR_SUCCESS                                            0          // 成功
#define ERROR_UNKNOWN                                            -1         // 未知错误
// 网络请求错误码
#define ERROR_NETWORK_SUCCESS                                    1000
#define ERROR_NETWORK_INVALID                                    -1000      // 网络无效错误
#define ERROR_NETWORK_RESP_INVALID                               -1001      // 网络返回内容无效
#define ERROR_NETWORK_UPLOAD_FAILED                              -1002      // 上传失败
#define ERROR_NETWORK_TOKEN_INVALID                              -1003      // 访问token失效
#define ERROR_NETWORK_UNKNOWN                                    1001       // 网络未知错误
#define ERROR_NETWORK_PARAMS                                     1002       // 传递给服务端的参数错误
#define ERROR_NETWORK_INTERNAL                                   1003       // 服务端内部错误
#define ERROR_NETWORK_SMSCODE_REPEATEDLY                         2003       // 短信验证码发送频繁
#define ERROR_NETWORK_AUTH_NOT_MATCH                             2005       // Auth跟用户不匹配
#define ERROR_NETWORK_AUTH_TOKEN_INVALID                         2006       // Auth token无效
#define ERROR_NETWORK_INVALID_API                                2009       // 无效请求
#define ERROR_NETWORK_AUTH_PASSWORD                              2010       // 登录的用户名或者密码错误
#define ERROR_NETWORK_APP_FORCE_UPDATE                           2011       // 接口作废
#define ERROR_NETWORK_APP_NOT_EXIST                              2012       // 接口版本不存在
#define ERROR_NETWORK_COMMON_PARAMS                              2013       // 公参不对
#define ERROR_NETWORK_SMS_CODE                                   2014       // 验证码错误
#define ERROR_NETWORK_USER_NOT_FOUND                             3001       // 未找到用户
#define ERROR_NETWORK_USER_NICKNAME_INVALID                      3002       // 昵称格式不对
#define ERROR_NETWORK_USER_NICKNAME_USED                         3003       // 昵称已被使用
#define ERROR_NETWORK_USER_NICKNAME_REFUSED                      3004       // 昵称不允许被使用
#define ERROR_NETWORK_USER_SEX_M_OUT                             3005       // 性别修改次数过多
#define ERROR_NETWORK_USER_NICKNAME_M_OUT                        3006       // 昵称修改频繁
#define ERROR_NETWORK_USER_INTRODUCTION                          3007       // 介绍格式不对
#define ERROR_NETWORK_USER_DEACTIVATE                            3011       // 用户注销
#define  ERROR_NETWORK_USER_BLOCKED                              3009       // 用户被系统block
#define ERROR_NETWORK_OBJECT_NOT_FOUND                           4001       // 未找到对象
#define ERROR_NETWORK_USER_CONFLICT                              4002       // 用户关注或者取关自己
#define ERROR_NETWORK_USER_BLOCK_ME                              4003       // 我被Block
#define ERROR_NETWORK_USER_BLOCK_USER                            4004       // 我Block user
#define ERROR_NETWORK_PIN_POST_MAX                               4008       // 置顶数量达上限
// 上传错误码
#define ERROR_UPLOADING_OFFSET_OUT                               -16001     // 上传offset超限
// IM本地错误码
#define ERROR_IM_DUPLICATE_SEND_MSG                              -18003     // 重复发送消息
#define ERROR_IM_SEND_MSG_RESOURCE_INVALID                       -18004     // 发送消息的资源无效
#define ERROR_IM_MSG_NOT_SUPPORT                                 -18005     // 不支持的消息类型
#define ERROR_IM_SEND_MSG_RESOURCE_FAILED                        -18006     // 上传资源失败
#define ERROR_IM_SOCKET_CLOSED                                   -18007     // 本地IM长链接已关闭
#define ERROR_IM_SEND_MSG_REFUSE                                 -18008     // IM发送消息被拒绝
#define ERROR_IM_SOCKET_TIMEOUT                                  -18009     // 本地IM长链接超时
// 本地错误码
#define ERROR_LOGIN_MOBILE_EMPTY                                 -19001     // 登录输入的手机号为空
#define ERROR_LOGIN_SMS_EMPTY                                    -19003     // 登录输入的短信验证码为空
#define ERROR_LOGIN_FAILED                                       -19004     // 其它登录失败错误
#define ERROR_USERINFO_NICKNAME_EMPTY                            -19005     // 用户昵称为空
#define ERROR_USERINFO_NICKNAME_TOO_SHORT                        -19006     // 昵称太短
#define ERROR_USERINFO_NICKNAME_TOO_LONG                         -19007     // 昵称太长
#define ERROR_USERINFO_HEAD_EMPTY                                -19008     // 用户头像为空
#define ERROR_USERINFO_FAILED                                    -19009     // 用户编辑失败
#define ERROR_POST_NOT_FOUND                                     -19010     // 用户编辑失败

#define POST_PIC_MAX_COUNT                                       9
#define POSTS_NUM_ONE_PAGE                                       15
#define COMMENTS_NUM_ONE_PAGE                                    20
#define USERS_NUM_ONE_PAGE                                       20
#define USER_ALBUMS_NUM_ONE_PAGE                                 15
#define IM_MESSAGES_ONE_PAGE                                     15
#define INTERESTS_NUM_ONE_PAGE                                   8
#define SUG_EMPTY_HIS_SHOW_NUM                                   5
#define SUG_HIS_SHOW_NUM                                         2
#define SUG_HIS_CACHE_NUM                                        20
#define SUG_SEARCH_ONE_PAGE_NUM                                  20
#define SUG_USERS_NUM_ONE_PAGE                                   20
#define SEARCH_POSTS_NUMBER_ONE_PAGE                             15
#define SEARCH_USERS_NUMBER_ONE_PAGE                             10
#define SUMMARY_LIMIT                                            275
#define FEED_CONTENT_MAX_LENGTH                                  1000
#define DEFAULT_HEADS_LIST_COUNT                                 2
#define DRAFT_MAX_COUNT                                          20
#define LBS_NEAR_REVIEW_USERS_COUNT                              6
#define MAX_VIDEO_RECORD_DURATION                                60.0
#define MAX_VIDEO_UPLOAD_QUALITY                                 25.0
#define MAX_IMAGE_UPLOAD_QUALITY                                 5.0
#define TEXT_CHECK_DELAY                                         300
#define Search_DELAY                                             300
#define CONTACTS_RECENT_NUM                                      5
#define RECOMMAND_TOPIC_NUM                                      20
#define INTRO_MAX_NUM                                            175
#define LOCATIONS_ONE_PAGE                                       20
#define Contacts_ONE_PAGE                                        300
#define VerticalPageCount                                        20
#define VerticalTypeCount                                        50
#define TrendingTopicsCount                                      20


#define ATTACHMENT_PIC_TYPE                                      @"IMAGE"
#define ATTACHMENT_VIDEO_TYPE                                    @"VIDEO"
#define ATTACHMENT_POLL_TYPE                                     @"POLL"
#define ADDITION_THUMB_TYPE                                      @"THUMB"


typedef NS_ENUM(NSInteger, WELIKE_PUSH_TYPE)
{
    WELIKE_PUSH_TYPE_UNKNOWN = 300,
    WELIKE_PUSH_TYPE_FOLLOW = 0,
    WELIKE_PUSH_TYPE_UNFOLLOW = 1,
    WELIKE_PUSH_TYPE_FORWARD = 2,
    WELIKE_PUSH_TYPE_POST_MENTION = 3,
    WELIKE_PUSH_TYPE_COMMENT_MENTION = 4,
    WELIKE_PUSH_TYPE_REPLY_MENTION = 5,
    WELIKE_PUSH_TYPE_COMMENT = 6,
    WELIKE_PUSH_TYPE_REPLY = 7,
    WELIKE_PUSH_TYPE_POST_LIKE = 8,
    WELIKE_PUSH_TYPE_COMMENT_LIKE = 9,
    WELIKE_PUSH_TYPE_REPLY_LIKE = 10,
    WELIKE_PUSH_TYPE_SUPER_LIKE = 11,
    WELIKE_PUSH_TYPE_FORWARD_COMMENT = 12,
    WELIKE_PUSH_TYPE_HTTP_URL_FORWARD = 13,
    WELIKE_PUSH_TYPE_FORWARD_POST = 14,
    WELIKE_PUSH_TYPE_MERGE_COMMENT = 51,
    WELIKE_PUSH_TYPE_MERGE_LIKE = 52,
    WELIKE_PUSH_TYPE_MERGE_FOLLOW = 53,
    WELIKE_PUSH_TYPE_MERGE_MEMTIION = 54,
    WELIKE_PUSH_TYPE_MERGE_NEW_POST = 55,
    WELIKE_PUSH_TYPE_MESSAGE_TEXT = 100,
    WELIKE_PUSH_TYPE_MESSAGE_PIC = 101,
    WELIKE_PUSH_TYPE_YUNYING_SMALL_PIC = 201,
    WELIKE_PUSH_TYPE_YUNYING_BIG_PIC = 202,
    WELIKE_PUSH_TYPE_YUNYING_BIG_TEXT = 203
};

#ifndef kiOS9Later
#define kiOS9Later                                               ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0)
#endif

#ifndef kiOS10Later
#define kiOS10Later                                              ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0)
#endif

#ifndef kiOS11Later
#define kiOS11Later                                              ([UIDevice currentDevice].systemVersion.doubleValue >= 11.0)
#endif

#define kWLMemoryWarningNotificationName                         @"kWLMemoryWarningNotificationName"
#define kWLAppWillResignActiveNotificationName                   @"kWLAppWillResignActiveNotificationName"
#define kWLAppDidBecomeActiveNotificationName                    @"kWLAppDidBecomeActiveNotificationName"
#define kWLAccountHonorUpdatedNotificationName                   @"kWLAccountHonorUpdatedNotificationName"

//UserDefault
#define kContactCurrentCursor                   @"kContactCurrentCursor"
#define kSelectionInterestsKey                  @"kSelectionInterestsKey"
#define kStatusListKey                          @"kStatusListKey"

#endif /* RDServiceGlobal_h */
