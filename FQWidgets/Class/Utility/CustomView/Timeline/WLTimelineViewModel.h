//
//  WLTimelineViewModel.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLFeedModel.h"

#define cellMarginY                         kSizeScale(10)  // cell 之间的留白

#define cellPaddingTop                      kSizeScale(10)  // 内容区域距上边的距离
#define cellPaddingLeft                     kSizeScale(15)  // 内容区域距左边的距离
#define cellAvatarSize                      kSizeScale(46)  // 头像大小
#define cellPaddingX                        kSizeScale(10)  // 内容之间的留白
#define cellPaddingY                        kSizeScale(10)  // 内容之间的留白
#define cellLineHeight                      kSizeScale(0.5) // 分割线
#define cellToolBarHeight                   kSizeScale(38)  // 底部操作栏高度
#define cellCardHeight                      kSizeScale(96)  // 口香糖卡片高度
#define cellVideoHeight                     kSizeScale(186) // 视频展示高度

#define cellNameFont                        [UIFont systemFontOfSize:kSizeScale(16)]
#define cellBodyFont                        [UIFont systemFontOfSize:kSizeScale(17)]
#define cellDescFont                        [UIFont systemFontOfSize:kSizeScale(15)]
#define cellDateTimeFont                    [UIFont systemFontOfSize:kSizeScale(14)]
#define cellLinkFont                        [UIFont systemFontOfSize:kSizeScale(12)]

@interface WLTimelineViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray<WLFeedModel *> *dataArray;

- (void)fetchListWithFinished:(void(^)(BOOL succeed, BOOL hasMore))finished;
- (void)fetchMoreWithFinished:(void(^)(BOOL succeed, BOOL hasMore))finished;

@end
