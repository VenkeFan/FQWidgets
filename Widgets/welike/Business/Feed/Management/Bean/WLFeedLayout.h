//
//  WLFeedLayout.h
//  welike
//
//  Created by fan qi on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPostBase.h"

@class WLPollPost;

#define cellSpacingY                        (kCommonCellSpacing)
#define cellPaddingTop                      (12)  // 内容区域距上边的距离
#define cellPaddingLeft                     (12)  // 内容区域距左边的距离
#define cellContentWidth                    (kScreenWidth - cellPaddingLeft * 2) // cell内容区域宽度
#define cellAvatarSize                      (kAvatarSizeMedium)  // 头像大小
#define cellPaddingX                        (8)  // 内容之间的留白
#define cellPaddingY                        (6)  // 内容之间的留白
#define cellLineHeight                      (0.5) // 分割线
#define cellToolBarHeight                   (49)  // 底部操作栏高度
#define cellCardHeight                      (64)  // 口香糖卡片高度
#define cellVideoHeight                     (180) // 视频展示高度
#define cellPicSpacing                      (3.0) // 图片之间的间隔
#define cellSeparateHeight                  (1.0)
#define cellArticleHeight                   (188)
#define cellOtherInfoHeight                 (14.0)

#define cellNameFont                        kBoldFont(14.0)
#define cellBodyFont                        kRegularFont(14.0)
#define cellDescFont                        kRegularFont(12.0)
#define cellDateTimeFont                    kRegularFont(10.0)

typedef NS_ENUM(NSInteger, WLFeedLayoutType) {
    WLFeedLayoutType_TimeLine,
    WLFeedLayoutType_FeedDetail,
    WLFeedLayoutType_RepostInDetail,
    WLFeedLayoutType_UserDetail,
    WLFeedLayoutType_TopicTop,
};

typedef NS_ENUM(NSInteger, WLFeedSourceType) {
    WLFeedSourceType_Home,              ///< Following
    WLFeedSourceType_Discover_Hot,      ///< Trending
    WLFeedSourceType_Discover_Latest,   ///< Rising
    WLFeedSourceType_Topic_Hot,
    WLFeedSourceType_Topic_Latest,
    WLFeedSourceType_UserDetail_Posts,
    WLFeedSourceType_UserDetail_Likes,
    WLFeedSourceType_Location_Hot,
    WLFeedSourceType_Location_Latest,
    WLFeedSourceType_UnLogin_Home,
    WLFeedSourceType_TopicTop,
    WLFeedSourceType_FeedDetail,
    WLFeedSourceType_RepostInDetail
};

@interface WLFeedLayout : NSObject

+ (instancetype)layoutWithFeedModel:(WLPostBase *)feedModel;
+ (instancetype)layoutWithFeedModel:(WLPostBase *)feedModel layoutType:(WLFeedLayoutType)layoutType;

- (instancetype)reLayoutWithPollModel:(WLPollPost *)newPollModel;

@property (nonatomic, assign) WLFeedLayoutType layoutType;

@property (nonatomic, strong, readonly) WLPostBase *feedModel;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, assign) CGFloat profileHeight;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect timeFrame;
@property (nonatomic, copy) NSString *souceTail;
@property (nonatomic, assign) CGRect readCountFrame;
@property (nonatomic, strong) NSAttributedString *readCountStr;

@property (nonatomic, assign) CGFloat textTop;
@property (nonatomic, assign) CGFloat textHeight;

@property (nonatomic, assign) CGSize picSize;
@property (nonatomic, assign) CGSize picGroupSize;
@property (nonatomic, assign) CGFloat picGroupTop;
@property (nonatomic, assign) CGFloat picGroupLeft;

@property (nonatomic, assign) CGSize voteViewSize;
@property (nonatomic, assign) CGSize voteGroupSize;
@property (nonatomic, assign) CGFloat voteGroupTop;
@property (nonatomic, assign) CGFloat voteGroupLeft;

@property (nonatomic, assign) CGSize articleSize;
@property (nonatomic, assign) CGFloat articleTop;
@property (nonatomic, assign) CGFloat articleLeft;

@property (nonatomic, assign) CGFloat otherInfoTop;

@property (nonatomic, assign) CGFloat videoLeft;
@property (nonatomic, assign) CGFloat videoTop;
@property (nonatomic, assign) CGSize videoSize;

@property (nonatomic, assign) CGFloat cardLeft;
@property (nonatomic, assign) CGFloat cardTop;
@property (nonatomic, assign) CGSize cardSize;

@property (nonatomic, assign) CGFloat retweetedViewTop;
@property (nonatomic, assign) CGFloat retweetedViewHeight;

@property (nonatomic, assign) CGFloat retweetedTextTop;
@property (nonatomic, assign) CGFloat retweetedTextHeight;

@property (nonatomic, strong) WLHandledFeedModel *handledFeedModel;
@property (nonatomic, strong) WLHandledFeedModel *rootPostHandledFeedModel;

@property (nonatomic, assign) BOOL followLoading;

@end
