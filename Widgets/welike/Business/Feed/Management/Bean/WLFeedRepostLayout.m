//
//  WLFeedRepostLayout.m
//  welike
//
//  Created by fan qi on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedRepostLayout.h"
#import "WLPicInfo.h"
#import "WLRichItem.h"
#import "WLTextPost.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLLinkPost.h"
#import "WLForwardPost.h"
#import "WLHandledFeedModel.h"
#import "NSDate+LuuBase.h"

@interface WLFeedRepostLayout ()

@property (nonatomic, strong, readwrite) WLPostBase *feedModel;

@end

@implementation WLFeedRepostLayout

+ (instancetype)layoutWithFeedModel:(WLPostBase *)feedModel {
    if (!feedModel) {
        return nil;
    }
    
    WLHandledFeedModel *richModel = nil;
    WLHandledFeedModel *rootPostRichModel = nil;
    if (feedModel.richContent != nil) {
        richModel = [[WLHandledFeedModel alloc] init];
        richModel.isSummaryDisplay = NO;
        richModel.font = reCellBodyFont;
        richModel.renderWidth = reCellContentWidth;
        richModel.lineBreakMode = NSLineBreakByCharWrapping;
        richModel.maxLineNum = 0;
        richModel.textColor = kBodyFontColor;
        [richModel handleRichModel:feedModel.richContent];
    }
    if (feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        WLForwardPost *forwardPost = (WLForwardPost *)feedModel;
        if (forwardPost.rootPost.richContent != nil) {
            rootPostRichModel = [[WLHandledFeedModel alloc] init];
            rootPostRichModel.isSummaryDisplay = NO;
            rootPostRichModel.font = reCellBodyFont;
            rootPostRichModel.renderWidth = reCellContentWidth;
            rootPostRichModel.lineBreakMode = NSLineBreakByCharWrapping;
            rootPostRichModel.maxLineNum = 0;
             rootPostRichModel.textColor = kBodyFontColor;
            [rootPostRichModel handleRichModel:forwardPost.rootPost.richContent];
        }
    }
    WLFeedRepostLayout *layout = [[WLFeedRepostLayout alloc] init];
    
    layout.feedModel = feedModel;
    layout.handledFeedModel = richModel;
    layout.rootPostHandledFeedModel = rootPostRichModel;
    [layout p_layoutFeedContentWithFeedModel:feedModel];
    
    return layout;
}

#pragma mark - Layout

- (void)p_layoutFeedContentWithFeedModel:(WLPostBase *)feedModel {
    CGFloat x = reCellPaddingLeft, y = reCellPaddingTop;
    
    {
        self.avatarFrame = CGRectMake(x, y, reCellAvatarSize, reCellAvatarSize);
        x += (CGRectGetWidth(self.avatarFrame) + reCellPaddingX);
    }
    
    {
        CGSize nameSize = [feedModel.nickName boundingRectWithSize:CGSizeMake(reCellContentWidth, reCellNameFont.pointSize + 5)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName: reCellNameFont}
                                                           context:nil].size;
        
        self.nameFrame = CGRectMake(x, y, ceilf(nameSize.width) + 10, ceilf(nameSize.height));
        y += (CGRectGetHeight(self.nameFrame) + 2);
    }
    
    {
        self.textFrame = CGRectMake(x, y, reCellContentWidth, self.handledFeedModel.richTextHeight);
        y += (CGRectGetHeight(self.textFrame) + reCellPaddingTop * 2);
    }
    
    {
        NSString *timeStr = [NSDate commentTimeStringFromTimestamp:feedModel.time];
        
        if (feedModel.from.length > 0) {
            self.souceTail = [NSString stringWithFormat:@"%@%@%@", timeStr ?: @"", [AppContext getStringForKey:@"feed_from" fileName:@"feed"], feedModel.from];
        } else {
            self.souceTail = [NSString stringWithFormat:@"%@", timeStr ?: @""];
        }
        
        CGSize timeSize = [self.souceTail boundingRectWithSize:CGSizeMake(reCellContentWidth, reCellAvatarSize)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: reCellDateTimeFont}
                                                       context:nil].size;
        self.timeFrame = CGRectMake(x, y, ceil(timeSize.width), ceil(timeSize.height));
        y += (CGRectGetHeight(self.timeFrame) + reCellPaddingTop);
    }
    
    {
        self.lineFrame = CGRectMake(x, y, reCellContentWidth, reCellLineHeight);
        y += CGRectGetHeight(self.lineFrame);
    }
    
    self.contentHeight = y;
    self.cellHeight = self.contentHeight;
}

@end
