//
//  WLFeedModel.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 认证方式
typedef NS_ENUM(NSUInteger, WLUserVerifyType){
    WLUserVerifyTypeNone = 0,     ///< 没有认证
    WLUserVerifyTypeStandard,     ///< 个人认证，黄V
    WLUserVerifyTypeOrganization, ///< 官方认证，蓝V
    WLUserVerifyTypeClub,         ///< 达人认证，红星
};


/// 图片标记
typedef NS_ENUM(NSUInteger, WLPictureBadgeType) {
    WLPictureBadgeTypeNone = 0, ///< 正常图片
    WLPictureBadgeTypeLong,     ///< 长图
    WLPictureBadgeTypeGIF,      ///< GIF
};

/**
一个图片的元数据
*/
@interface WLPictureMetadata : NSObject
@property (nonatomic, strong) NSURL *url; ///< Full image url
@property (nonatomic, assign) int width; ///< pixel width
@property (nonatomic, assign) int height; ///< pixel height
@property (nonatomic, copy) NSString *type; ///< "WEBP" "JPEG" "GIF"
@property (nonatomic, assign) int cutType; ///< Default:1
@property (nonatomic, assign) WLPictureBadgeType badgeType;
@end


/**
 图片
 */
@interface WLPicture : NSObject
@property (nonatomic, copy) NSString *picID;
@property (nonatomic, copy) NSString *objectID;
@property (nonatomic, assign) int photoTag;
@property (nonatomic, assign) BOOL keepSize; ///< YES:固定为方形 NO:原始宽高比
@property (nonatomic, strong) WLPictureMetadata *thumbnail;  ///< w:180
@property (nonatomic, strong) WLPictureMetadata *bmiddle;    ///< w:360 (列表中的缩略图)
@property (nonatomic, strong) WLPictureMetadata *middlePlus; ///< w:480
@property (nonatomic, strong) WLPictureMetadata *large;      ///< w:720 (放大查看)
@property (nonatomic, strong) WLPictureMetadata *largest;    ///<       (查看原图)
@property (nonatomic, strong) WLPictureMetadata *original;   ///<
@property (nonatomic, assign) WLPictureBadgeType badgeType;
@end


/**
 链接
 */
@interface WLURL : NSObject
@property (nonatomic, assign) BOOL result;
@property (nonatomic, copy) NSString *shortURL; ///< 短域名 (原文)
@property (nonatomic, copy) NSString *oriURL;   ///< 原始链接
@property (nonatomic, copy) NSString *urlTitle; ///< 显示文本，例如"网页链接"，可能需要裁剪(24)
@property (nonatomic, copy) NSString *urlTypePic; ///< 链接类型的图片URL
@property (nonatomic, assign) int32_t urlType; ///< 0:一般链接 36地点 39视频/图片
@property (nonatomic, copy) NSString *log;
@property (nonatomic, strong) NSDictionary *actionLog;
@property (nonatomic, copy) NSString *pageID; ///< 对应着 WLPageInfo
@property (nonatomic, copy) NSString *storageType;
//如果是图片，则会有下面这些，可以直接点开看
@property (nonatomic, strong) NSArray<NSString *> *picIds;
@property (nonatomic, strong) NSDictionary<NSString *, WLPicture *> *picInfos;
@property (nonatomic, strong) NSArray<WLPicture *> *pics;
@end


/**
 话题
 */
@interface WLTopic : NSObject
@property (nonatomic, copy) NSString *topicTitle; ///< 话题标题
@property (nonatomic, copy) NSString *topicURL; ///< 话题链接 sinaweibo://
@end


/**
 标签
 */
@interface WLTag : NSObject
@property (nonatomic, copy) NSString *tagName; ///< 标签名字，例如"上海·上海文庙"
@property (nonatomic, copy) NSString *tagScheme; ///< 链接 sinaweibo://...
@property (nonatomic, assign) int32_t tagType; ///< 1 地点 2其他
@property (nonatomic, assign) int32_t tagHidden;
@property (nonatomic, strong) NSURL *urlTypePic; ///< 需要加 _default
@end


/**
 按钮
 */
@interface WLButtonLink : NSObject
@property (nonatomic, strong) NSURL *pic;  ///< 按钮图片URL (需要加_default)
@property (nonatomic, copy) NSString *name; ///< 按钮文本，例如"点评"
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSDictionary *params;
@end


/**
 卡片 (样式有多种，最常见的是下方这样)
 -----------------------------
 title
 pic     title        button
 tips
 -----------------------------
 */
@interface WLPageInfo : NSObject
@property (nonatomic, copy) NSString *pageTitle; ///< 页面标题，例如"上海·上海文庙"
@property (nonatomic, copy) NSString *pageID;
@property (nonatomic, copy) NSString *pageDesc; ///< 页面描述，例如"上海市黄浦区文庙路215号"
@property (nonatomic, copy) NSString *content1;
@property (nonatomic, copy) NSString *content2;
@property (nonatomic, copy) NSString *content3;
@property (nonatomic, copy) NSString *content4;
@property (nonatomic, copy) NSString *tips; ///< 提示，例如"4222条微博"
@property (nonatomic, copy) NSString *objectType; ///< 类型，例如"place" "video"
@property (nonatomic, copy) NSString *objectID;
@property (nonatomic, copy) NSString *scheme; ///< 真实链接，例如 http://v.qq.com/xxx
@property (nonatomic, strong) NSArray<WLButtonLink *> *buttons;

@property (nonatomic, assign) int32_t isAsyn;
@property (nonatomic, assign) int32_t type;
@property (nonatomic, copy) NSString *pageURL; ///< 链接 sinaweibo://...
@property (nonatomic, strong) NSURL *pagePic; ///< 图片URL，不需要加(_default) 通常是左侧的方形图片
@property (nonatomic, strong) NSURL *typeIcon; ///< Badge 图片URL，不需要加(_default) 通常放在最左上角角落里
@property (nonatomic, assign) int32_t actStatus;
@property (nonatomic, strong) NSDictionary *actionlog;
@property (nonatomic, strong) NSDictionary *mediaInfo;
@end

/**
 微博标题
 */
@interface WLFeedModelTitle : NSObject
@property (nonatomic, assign) int32_t baseColor;
@property (nonatomic, copy) NSString *text; ///< 文本，例如"仅自己可见"
@property (nonatomic, copy) NSString *iconURL; ///< 图标URL，需要加Default
@end

/**
 用户
 */
@interface WLUser : NSObject
@property (nonatomic, assign) uint64_t userID; ///< id (int)
@property (nonatomic, copy) NSString *idString; ///< id (string)
@property (nonatomic, assign) int32_t gender; /// 0:none 1:男 2:女
@property (nonatomic, copy) NSString *genderString; /// "m":男 "f":女 "n"未知
@property (nonatomic, copy) NSString *desc; ///< 个人简介
@property (nonatomic, copy) NSString *domain; ///< 个性域名

@property (nonatomic, copy) NSString *name; ///< 昵称
@property (nonatomic, copy) NSString *screenName; ///< 友好昵称
@property (nonatomic, copy) NSString *remark; ///< 备注

@property (nonatomic, assign) int32_t followersCount; ///< 粉丝数
@property (nonatomic, assign) int32_t friendsCount; ///< 关注数
@property (nonatomic, assign) int32_t biFollowersCount; ///< 好友数 (双向关注)
@property (nonatomic, assign) int32_t favouritesCount; ///< 收藏数
@property (nonatomic, assign) int32_t statusesCount; ///< 微博数
@property (nonatomic, assign) int32_t topicsCount; ///< 话题数
@property (nonatomic, assign) int32_t blockedCount; ///< 屏蔽数
@property (nonatomic, assign) int32_t pagefriendsCount;
@property (nonatomic, assign) BOOL followMe;
@property (nonatomic, assign) BOOL following;

@property (nonatomic, copy) NSString *province; ///< 省
@property (nonatomic, copy) NSString *city;     ///< 市

@property (nonatomic, copy) NSString *url; ///< 博客地址
@property (nonatomic, strong) NSURL *profileImageURL; ///< 头像 50x50 (FeedList)
@property (nonatomic, strong) NSURL *avatarLarge;     ///< 头像 180*180
@property (nonatomic, strong) NSURL *avatarHD;        ///< 头像 原图
@property (nonatomic, strong) NSURL *coverImage;      ///< 封面图 920x300
@property (nonatomic, strong) NSURL *coverImagePhone;

@property (nonatomic, copy) NSString *profileURL;
@property (nonatomic, assign) int32_t type;
@property (nonatomic, assign) int32_t ptype;
@property (nonatomic, assign) int32_t mbtype;
@property (nonatomic, assign) int32_t urank; ///< 微博等级 (LV)
@property (nonatomic, assign) int32_t uclass;
@property (nonatomic, assign) int32_t ulevel;
@property (nonatomic, assign) int32_t mbrank; ///< 会员等级 (橙名 VIP)
@property (nonatomic, assign) int32_t star;
@property (nonatomic, assign) int32_t level;
@property (nonatomic, strong) NSDate *createdAt; ///< 注册时间
@property (nonatomic, assign) BOOL allowAllActMsg;
@property (nonatomic, assign) BOOL allowAllComment;
@property (nonatomic, assign) BOOL geoEnabled;
@property (nonatomic, assign) int32_t onlineStatus;
@property (nonatomic, copy) NSString *location; ///< 所在地
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *icons;
@property (nonatomic, copy) NSString *weihao;
@property (nonatomic, copy) NSString *badgeTop;
@property (nonatomic, assign) int32_t blockWord;
@property (nonatomic, assign) int32_t blockApp;
@property (nonatomic, assign) int32_t hasAbilityTag;
@property (nonatomic, assign) int32_t creditScore; ///< 信用积分
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *badge; ///< 勋章
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, assign) int32_t userAbility;
@property (nonatomic, strong) NSDictionary *extend;

@property (nonatomic, assign) BOOL verified; ///< 微博认证 (大V)
@property (nonatomic, assign) int32_t verifiedType;
@property (nonatomic, assign) int32_t verifiedLevel;
@property (nonatomic, assign) int32_t verifiedState;
@property (nonatomic, copy) NSString *verifiedContactEmail;
@property (nonatomic, copy) NSString *verifiedContactMobile;
@property (nonatomic, copy) NSString *verifiedTrade;
@property (nonatomic, copy) NSString *verifiedContactName;
@property (nonatomic, copy) NSString *verifiedSource;
@property (nonatomic, copy) NSString *verifiedSourceURL;
@property (nonatomic, copy) NSString *verifiedReason; ///< 微博认证描述
@property (nonatomic, copy) NSString *verifiedReasonURL;
@property (nonatomic, copy) NSString *verifiedReasonModified;

@property (nonatomic, assign) WLUserVerifyType userVerifyType;

@end

@interface WLFeedLayout : NSObject

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, assign) CGFloat profileHeight;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect timeFrame;

@property (nonatomic, assign) CGFloat textTop;
@property (nonatomic, assign) CGFloat textHeight;

@property (nonatomic, assign) CGSize picSize;
@property (nonatomic, assign) CGSize picGroupSize;
@property (nonatomic, assign) CGFloat picGroupTop;

@property (nonatomic, assign) CGFloat cardTop;

@property (nonatomic, assign) CGFloat retweetedViewTop;
@property (nonatomic, assign) CGFloat retweetedViewHeight;

@property (nonatomic, assign) CGFloat retweetedTextTop;
@property (nonatomic, assign) CGFloat retweetedTextHeight;

@property (nonatomic, copy) NSAttributedString *retweetedText;

@end

/**
 微博
 */
@interface WLFeedModel : NSObject

@property (nonatomic, strong) WLFeedLayout *layout;

@property (nonatomic, assign) uint64_t statusID; ///< id (number)
@property (nonatomic, copy) NSString *idstr; ///< id (string)
@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *rid;
@property (nonatomic, strong) NSDate *createdAt; ///< 发布时间

@property (nonatomic, strong) WLUser *user;
@property (nonatomic, assign) int32_t userType;

@property (nonatomic, strong) WLFeedModelTitle *title; ///< 标题栏 (通常为nil)
@property (nonatomic, copy) NSString *picBg; ///< 微博VIP背景图，需要替换 "os7"
@property (nonatomic, copy) NSString *text; ///< 正文
@property (nonatomic, strong) NSURL *thumbnailPic; ///< 缩略图
@property (nonatomic, strong) NSURL *bmiddlePic; ///< 中图
@property (nonatomic, strong) NSURL *originalPic; ///< 大图

@property (nonatomic, strong) WLFeedModel *retweetedStatus; ///转发微博

@property (nonatomic, strong) NSArray<NSString *> *picIds;
@property (nonatomic, strong) NSDictionary<NSString *, WLPicture *> *picInfos;

@property (nonatomic, strong) NSArray<WLPicture *> *pics;
@property (nonatomic, strong) NSArray<WLURL *> *urlStruct;
@property (nonatomic, strong) NSArray<WLTopic *> *topicStruct;
@property (nonatomic, strong) NSArray<WLTag *> *tagStruct;
@property (nonatomic, strong) WLPageInfo *pageInfo;

@property (nonatomic, assign) BOOL favorited; ///< 是否收藏
@property (nonatomic, assign) BOOL truncated;  ///< 是否截断
@property (nonatomic, assign) int32_t repostsCount; ///< 转发数
@property (nonatomic, assign) int32_t commentsCount; ///< 评论数
@property (nonatomic, assign) int32_t attitudesCount; ///< 赞数
@property (nonatomic, assign) int32_t attitudesStatus; ///< 是否已赞 0:没有
@property (nonatomic, assign) int32_t recomState;

@property (nonatomic, copy) NSString *inReplyToScreenName;
@property (nonatomic, copy) NSString *inReplyToStatusId;
@property (nonatomic, copy) NSString *inReplyToUserId;

@property (nonatomic, copy) NSString *source; ///< 来自 XXX
@property (nonatomic, assign) int32_t sourceType;
@property (nonatomic, assign) int32_t sourceAllowClick; ///< 来源是否允许点击

@property (nonatomic, strong) NSDictionary *geo;
@property (nonatomic, strong) NSArray *annotations; ///< 地理位置
@property (nonatomic, assign) int32_t bizFeature;
@property (nonatomic, assign) int32_t mlevel;
@property (nonatomic, copy) NSString *mblogid;
@property (nonatomic, copy) NSString *mblogTypeName;
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, strong) NSDictionary *visible;
@property (nonatomic, strong) NSArray *darwinTags;
@end


/**
 一次API请求的数据
 */
@interface WLTimelineItem : NSObject
@property (nonatomic, strong) NSArray *ad;
@property (nonatomic, strong) NSArray *advertises;
@property (nonatomic, copy) NSString *gsid;
@property (nonatomic, assign) int32_t interval;
@property (nonatomic, assign) int32_t uveBlank;
@property (nonatomic, assign) int32_t hasUnread;
@property (nonatomic, assign) int32_t totalNumber;
@property (nonatomic, copy) NSString *sinceID;
@property (nonatomic, copy) NSString *maxID;
@property (nonatomic, copy) NSString *previousCursor;
@property (nonatomic, copy) NSString *nextCursor;
@property (nonatomic, strong) NSArray<WLFeedModel *> *statuses;
/*
 groupInfo
 trends
 */
@end
