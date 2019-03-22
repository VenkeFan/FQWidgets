//
//  WLFeedLayout.m
//  welike
//
//  Created by fan qi on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedLayout.h"
#import "WLPicInfo.h"
#import "WLRichItem.h"
#import "WLTextPost.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLLinkPost.h"
#import "WLForwardPost.h"
#import "WLPollPost.h"
#import "WLArticalPostModel.h"
#import "WLHandledFeedModel.h"
#import "NSDate+LuuBase.h"
#import "WLTextParse.h"

@interface WLFeedLayout ()

@property (nonatomic, strong, readwrite) WLPostBase *feedModel;

@end

@implementation WLFeedLayout

+ (instancetype)layoutWithFeedModel:(WLPostBase *)feedModel {
    return [WLFeedLayout layoutWithFeedModel:feedModel layoutType:WLFeedLayoutType_TimeLine];
}

+ (instancetype)layoutWithFeedModel:(WLPostBase *)feedModel layoutType:(WLFeedLayoutType)layoutType {
    if (!feedModel) {
        return nil;
    }
    
    WLHandledFeedModel *richModel = nil;
    WLHandledFeedModel *rootPostRichModel = nil;
    if (feedModel.richContent != nil) {
        richModel = [[WLHandledFeedModel alloc] init];
        if (layoutType == WLFeedLayoutType_TimeLine || layoutType == WLFeedLayoutType_UserDetail) {
            richModel.isSummaryDisplay = YES;
        } else {
            richModel.isSummaryDisplay = NO;
        }
        
        richModel.font = cellBodyFont;
        richModel.renderWidth = cellContentWidth;
        richModel.lineBreakMode = NSLineBreakByCharWrapping;
        richModel.maxLineNum = 0;
        richModel.textColor = kRichContentNormalColor;
        
        //在这里更改加入定位
        if (feedModel.location.place.length > 0)
        {
            richModel.location = feedModel.location;
        }
        
      //在这里修改text,summary和index,length,为了显示link
        WLRichContent *postContent = [[WLRichContent alloc] init];
        postContent.richItemList = [feedModel.richContent copyRichItemList];
        postContent.text = [NSString stringWithString:feedModel.richContent.text];
        if (feedModel.richContent.summary.length == 0)
        {
            postContent.summary = feedModel.richContent.text;
        }
        else
        {
            postContent.summary = [NSString stringWithString:feedModel.richContent.summary];
        }
        NSArray *urlitems = [WLTextParse keywordRangesOfURLInString:postContent.richItemList];
        
        if (urlitems.count > 0)
        {
            for (int i = 0; i < urlitems.count; i++)
            {
                WLRichItem *item = urlitems[i];

                if (item.title.length > 0)
                {
                    if (item.index + item.length <= postContent.text.length)
                    {
                       postContent.text = [postContent.text stringByReplacingCharactersInRange:NSMakeRange(item.index+1, item.length-1) withString:item.title];
                    
                    }


                    if (item.index + item.length <= postContent.summary.length)
                    {
                        postContent.summary = [postContent.summary stringByReplacingCharactersInRange:NSMakeRange(item.index+1, item.length-1) withString:item.title];
                    }
                    
                    NSInteger chazhi = item.title.length + 1 - item.length;

                    item.length = item.title.length + 1;
                    
                    for (int j = 0; j < postContent.richItemList.count; j++)
                    {
                        WLRichItem *otherItem = postContent.richItemList[j];
                        if (otherItem.index > item.index)
                        {
                            otherItem.index += chazhi;
                        }
                    }

                }
                else
                {
                    if (item.display.length > 0)
                    {
                        if (item.index + item.length <= postContent.text.length)
                        {
                            postContent.text = [postContent.text stringByReplacingCharactersInRange:NSMakeRange(item.index, item.length) withString:item.display];
                        }
                        
                        
                        if (item.index + item.length <= postContent.summary.length)
                        {
                            postContent.summary = [postContent.summary stringByReplacingCharactersInRange:NSMakeRange(item.index, item.length) withString:item.display];
                        }
                        NSInteger chazhi = item.display.length - item.length;

                        item.length = item.display.length;
                        
                        for (int j = 0; j < postContent.richItemList.count; j++)
                        {
                            WLRichItem *otherItem = postContent.richItemList[j];
                            if (otherItem.index > item.index)
                            {
                                otherItem.index += chazhi;
                            }
                        }

                    }
                    else
                    {
                        //不处理
                    }
                }
            }

             [richModel handleRichModel:postContent];
        }
        else
        {
             [richModel handleRichModel:feedModel.richContent];
        }
    }
    if (feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        WLForwardPost *forwardPost = (WLForwardPost *)feedModel;
        if (forwardPost.rootPost.richContent != nil) {
            rootPostRichModel = [[WLHandledFeedModel alloc] init];
            if (layoutType == WLFeedLayoutType_TimeLine || layoutType == WLFeedLayoutType_UserDetail) {
                rootPostRichModel.isSummaryDisplay = YES;
            } else {
                rootPostRichModel.isSummaryDisplay = NO;
            }
            rootPostRichModel.font = cellBodyFont;
            rootPostRichModel.renderWidth = cellContentWidth;
            rootPostRichModel.lineBreakMode = NSLineBreakByCharWrapping;
            rootPostRichModel.maxLineNum = 0;
            rootPostRichModel.textColor = kRichContentNormalColor;
            
            
            //增加一个link显示处理
            WLRichContent *contentOfLink = [[WLRichContent alloc] init];
            contentOfLink.richItemList = [forwardPost.rootPost.richContent copyRichItemList];
            contentOfLink.text = [NSString stringWithString:forwardPost.rootPost.richContent.text];
            if (forwardPost.rootPost.richContent.summary.length == 0)
            {
                contentOfLink.summary = contentOfLink.text;
            }
            else
            {
                contentOfLink.summary =  [NSString stringWithString:forwardPost.rootPost.richContent.summary];
            }
            NSArray *urlitems = [WLTextParse keywordRangesOfURLInString:contentOfLink.richItemList];
            
            if (urlitems.count > 0)
            {
                for (int i = 0; i < urlitems.count; i++)
                {
                    WLRichItem *item = urlitems[i];
                    
                    if (item.title.length > 0)
                    {
                        if (item.index + item.length <= contentOfLink.text.length)
                        {
                            contentOfLink.text = [contentOfLink.text stringByReplacingCharactersInRange:NSMakeRange(item.index+1, item.length-1) withString:item.title];
                        }
                        
                        
                        if (item.index + item.length <= contentOfLink.summary.length)
                        {
                            contentOfLink.summary = [contentOfLink.summary stringByReplacingCharactersInRange:NSMakeRange(item.index+1, item.length-1) withString:item.title];
                        }
                        
                        NSInteger chazhi = item.title.length + 1 - item.length;
                        
                        item.length = item.title.length + 1;
                        
                        for (int j = 0; j < contentOfLink.richItemList.count; j++)
                        {
                            WLRichItem *otherItem = contentOfLink.richItemList[j];
                            if (otherItem.index > item.index)
                            {
                                otherItem.index += chazhi;
                            }
                        }
                        
                        
                    }
                    else
                    {
                          if (item.display.length > 0 )
                        {
                            if (item.index + item.length <= contentOfLink.text.length)
                            {
                                contentOfLink.text = [contentOfLink.text stringByReplacingCharactersInRange:NSMakeRange(item.index, item.length) withString:item.display];
                            }
                            
                            
                            if (item.index + item.length <= contentOfLink.summary.length)
                            {
                                contentOfLink.summary = [contentOfLink.summary stringByReplacingCharactersInRange:NSMakeRange(item.index, item.length) withString:item.display];
                            }
                            
                            NSInteger chazhi = item.display.length - item.length;
                            
                            item.length = item.display.length;
                            
                            for (int j = 0; j < contentOfLink.richItemList.count; j++)
                            {
                                WLRichItem *otherItem = contentOfLink.richItemList[j];
                                if (otherItem.index > item.index)
                                {
                                    otherItem.index += chazhi;
                                }
                            }
                            
                        }
                        else
                        {
                            //不处理
                        }
                    }
                }
            }
           
            WLRichContent *forwardContent = [[WLRichContent alloc] init];
            forwardContent.text = [NSString stringWithFormat:@"@%@:%@",forwardPost.rootPost.nickName,contentOfLink.text];
            forwardContent.summary = [NSString stringWithFormat:@"@%@:%@",forwardPost.rootPost.nickName,contentOfLink.summary];
            
          
            WLRichItem *nameItem = [[WLRichItem alloc] init];
            nameItem.type = WLRICH_TYPE_MENTION;
            nameItem.index = 0;
            nameItem.length = [NSString stringWithFormat:@"@%@",forwardPost.rootPost.nickName].length;
            nameItem.source = [NSString stringWithFormat:@"@%@",forwardPost.rootPost.nickName];
            nameItem.rid = forwardPost.rootPost.uid;
            nameItem.target = @"";
            nameItem.title = @"";
            nameItem.icon = @"";
            nameItem.display = [NSString stringWithFormat:@"@%@",forwardPost.rootPost.nickName];
       
           NSMutableArray *newList = [NSMutableArray arrayWithCapacity:0];
            [newList addObjectsFromArray:[contentOfLink copyRichItemList]];
            
            for (int i = 0; i < newList.count; i++)
            {
                WLRichItem *richItem = newList[i];
                richItem.index = richItem.index + forwardPost.rootPost.nickName.length + 2;
            }
            [newList insertObject:nameItem atIndex:0];
            forwardContent.richItemList = [NSArray arrayWithArray:newList];
            [rootPostRichModel handleRichModel:forwardContent];
        }
    }
    WLFeedLayout *layout = [[WLFeedLayout alloc] init];
    layout.followLoading = NO;
    layout.layoutType = layoutType;
    
    layout.feedModel = feedModel;
    layout.handledFeedModel = richModel;
    layout.rootPostHandledFeedModel = rootPostRichModel;
    [layout p_layoutFeedContentWithFeedModel:feedModel];
    
    return layout;
}

- (instancetype)reLayoutWithPollModel:(WLPollPost *)newPollModel {
    WLFeedLayout *newLayout = nil;
    if (self.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        WLForwardPost *forwardModel = (WLForwardPost *)self.feedModel;
        if (forwardModel.rootPost.type == WELIKE_POST_TYPE_POLL) {
            WLPollPost *originPollModel = (WLPollPost *)forwardModel.rootPost;
            if ([originPollModel.pollID isEqualToString:newPollModel.pollID]) {
                [originPollModel reset:newPollModel];
                newLayout = [WLFeedLayout layoutWithFeedModel:forwardModel layoutType:self.layoutType];
            }
        }
    } else if (self.feedModel.type == WELIKE_POST_TYPE_POLL) {
        WLPollPost *originPollModel = (WLPollPost *)self.feedModel;
        if ([originPollModel.pollID isEqualToString:newPollModel.pollID]) {
            [originPollModel reset:newPollModel];
            newLayout = [WLFeedLayout layoutWithFeedModel:originPollModel layoutType:self.layoutType];
        }
    }
    
    return newLayout;
}

#pragma mark - Layout

- (void)p_layoutFeedContentWithFeedModel:(WLPostBase *)feedModel {
    CGFloat y = 0;
    
    [self p_layoutProfileWithFeedModel:feedModel];
    y += (self.profileHeight + cellPaddingY);
    
    [self p_layoutTextWithFeedModel:feedModel];
    self.textTop = y;
    y += (self.textHeight + cellPaddingY);
    
    if (self.layoutType == WLFeedLayoutType_RepostInDetail) {
        self.contentHeight = y;
        self.cellHeight = cellPaddingTop + self.contentHeight + cellSpacingY;
        return;
    }
    
    if (feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        WLForwardPost *retweetedModel = (WLForwardPost *)feedModel;
        if (retweetedModel.forwardDeleted) {
            self.retweetedViewTop = y;
            y += (cellCardHeight + cellPaddingY);
        } else {
            [self p_layoutRetweeted:retweetedModel];
            self.retweetedViewTop = y;
            self.retweetedTextTop = self.retweetedViewTop + cellPaddingY;
            CGFloat top = self.retweetedTextTop + self.retweetedTextHeight + cellPaddingY;
            self.picGroupTop = top;
            self.videoTop = top;
            self.cardTop = top;
            self.voteGroupTop = top;
            self.articleTop = top;
            self.otherInfoTop = top;
            y += (self.retweetedViewHeight + cellPaddingY);
            
            self.voteGroupLeft = 0;
            self.articleLeft = 0;
            self.picGroupLeft = 0;
            self.videoLeft = 0;
            self.cardLeft = 0;
        }
        
    } else if (feedModel.type == WELIKE_POST_TYPE_PIC) {
        [self p_layoutPictures:(WLPicPost *)feedModel width:kScreenWidth];
        self.picGroupTop = y;
        self.picGroupLeft = -cellPaddingLeft;
        y += (self.picGroupSize.height + cellPaddingY);
    } else if (feedModel.type == WELIKE_POST_TYPE_VIDEO) {
        self.videoTop = y;
        self.videoLeft = -cellPaddingLeft;
        [self p_layoutVideo:(WLVideoPost *)feedModel width:kScreenWidth];
        y += (self.videoSize.height + cellPaddingY);
    } else if (feedModel.type == WELIKE_POST_TYPE_LINK) {
        self.cardTop = y;
        self.cardLeft = -cellPaddingLeft;
        self.cardSize = CGSizeMake(kScreenWidth, cellCardHeight);
        y += (cellCardHeight + cellPaddingY);
    } else if (feedModel.type == WELIKE_POST_TYPE_POLL) {
        [self p_layoutPoll:(WLPollPost *)feedModel width:kScreenWidth];
        self.voteGroupTop = y;
        self.voteGroupLeft = -cellPaddingLeft;
        y += (self.voteGroupSize.height);
    } else if (feedModel.type == WELIKE_POST_TYPE_ARTICAL) {
        [self p_layoutArticle:(WLArticalPostModel *)feedModel width:kScreenWidth];
        self.articleTop = y;
        self.articleLeft = -cellPaddingLeft;
        y += self.articleSize.height;
    }
    
    if (self.layoutType == WLFeedLayoutType_FeedDetail) {
        self.otherInfoTop = y;
        y += (cellOtherInfoHeight + cellPaddingY);
        self.cellHeight = 0;
    } else {
        self.cellHeight = cellToolBarHeight;
    }
    
    self.contentHeight = y;
    self.cellHeight += (cellPaddingTop + self.contentHeight + cellSpacingY);
}

- (void)p_layoutProfileWithFeedModel:(WLPostBase *)feedModel {
    CGFloat x = cellAvatarSize + cellPaddingX;
    CGFloat y = 3;
    
    CGSize nameSize = [feedModel.nickName boundingRectWithSize:CGSizeMake(cellContentWidth - x, cellAvatarSize)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: cellNameFont}
                                                       context:nil].size;
    
    CGRect nameFrame = CGRectMake(x, y, ceilf(nameSize.width), ceilf(nameSize.height));
    y += (nameFrame.size.height + 4);
    
    NSString *timeStr = @"";
    switch (self.layoutType) {
        case WLFeedLayoutType_TimeLine:
        case WLFeedLayoutType_UserDetail:
        case WLFeedLayoutType_TopicTop:
        case WLFeedLayoutType_FeedDetail:
            timeStr = [NSDate feedTimeStringFromTimestamp:feedModel.time];
            break;
        case WLFeedLayoutType_RepostInDetail:
            timeStr = [NSDate commentTimeStringFromTimestamp:feedModel.time];
            break;
    }
    
    if (feedModel.from.length > 0) {
        self.souceTail = [NSString stringWithFormat:@"%@%@%@", timeStr ?: @"", [AppContext getStringForKey:@"feed_from" fileName:@"feed"], feedModel.from];
    } else {
        self.souceTail = [NSString stringWithFormat:@"%@", timeStr ?: @""];
    }
    
    CGFloat timeHeight = [self.souceTail boundingRectWithSize:CGSizeMake(cellContentWidth - x, cellAvatarSize)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: cellDateTimeFont}
                                                      context:nil].size.height;
    CGRect timeFrame = CGRectMake(x, y, cellContentWidth - x, timeHeight);
    
    
    if ([feedModel.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]
        && self.layoutType == WLFeedLayoutType_UserDetail) {
        self.readCountFrame = CGRectMake(0, 0, 42, 30);
        
        NSMutableString *readCountStrM = [NSMutableString string];
        NSString *suffix = [AppContext getStringForKey:@"feed_read_count" fileName:@"feed"];
        
        if (feedModel.readCount <= 9999) {
            [readCountStrM appendString:[NSString stringWithFormat:@"%zd", feedModel.readCount]];
        } else if (feedModel.readCount <= 9999999) {
            [readCountStrM appendString:[NSString stringWithFormat:@"%zd", feedModel.readCount / 1000]];
            [readCountStrM appendString:@"k"];
        } else {
            [readCountStrM appendString:[NSString stringWithFormat:@"%zd", feedModel.readCount / 1000000]];
            [readCountStrM appendString:@"m"];
        }
        [readCountStrM appendString:@"\r"];
        [readCountStrM appendString:suffix ?: @""];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = -1;
        style.alignment = NSTextAlignmentCenter;
        self.readCountStr = [[NSAttributedString alloc] initWithString:readCountStrM ?: @""
                                                            attributes:@{NSParagraphStyleAttributeName: style}];
    }
    
    self.nameFrame = nameFrame;
    self.timeFrame = timeFrame;
    self.profileHeight = cellAvatarSize;
}

- (void)p_layoutTextWithFeedModel:(WLPostBase *)feedModel {
//    CGFloat height = [feedModel.richContent.text boundingRectWithSize:CGSizeMake(cellContentWidth, kScreenHeight)
//                                                  options:NSStringDrawingUsesLineFragmentOrigin
//                                               attributes:@{NSFontAttributeName: cellBodyFont}
//                                                  context:nil].size.height;
//    self.textHeight = height;
    
    self.textHeight = self.handledFeedModel.richTextHeight;
}

- (void)p_layoutPictures:(WLPicPost *)feedModel width:(CGFloat)width {
    if (feedModel.picInfoList.count == 0) {
        self.picSize = self.picGroupSize = CGSizeZero;
        return;
    }
    
    CGFloat contentWidth = width;
    
    for (int i = 0; i < feedModel.picInfoList.count; i++) {
        [feedModel.picInfoList[i] calculatePicThumbnailInfoWithWidth:contentWidth];
    }
    
    if (feedModel.picInfoList.count == 1) {
        WLPicInfo *pic = feedModel.picInfoList.firstObject;
        CGFloat width = pic.thumbnailWidth;
        CGFloat height = pic.thumbnailHeight;
        
        width = width <= 0 ? contentWidth : width;
        height = height <= 0 ? contentWidth : height;
        
        self.picSize = self.picGroupSize = CGSizeMake(width, height);
        return;
    }
    
    NSInteger numberInRow = 3;
    
    if (feedModel.picInfoList.count == 2 || feedModel.picInfoList.count == 4) {
        numberInRow = 2;
    }
    CGFloat picWidth = (contentWidth - (numberInRow - 1) * cellPicSpacing) / numberInRow;
    
    CGFloat totalWidth = feedModel.picInfoList.count >= numberInRow
    ? numberInRow * (picWidth + cellPicSpacing) - cellPicSpacing
    : feedModel.picInfoList.count * (picWidth + cellPicSpacing) - cellPicSpacing;
    
    CGFloat totalHeight = ceilf((feedModel.picInfoList.count / (float)numberInRow)) * (picWidth + cellPicSpacing) - cellPicSpacing;
    
    self.picSize = CGSizeMake(picWidth, picWidth);
    self.picGroupSize = CGSizeMake(totalWidth, totalHeight);
}

- (void)p_layoutVideo:(WLVideoPost *)feedModel width:(CGFloat)width {
    [feedModel calculatePicThumbnailInfoWithWidth:width];
    self.videoSize = CGSizeMake(feedModel.thumbnailWidth, feedModel.thumbnailHeight);
}

- (void)p_layoutPoll:(WLPollPost *)feedModel width:(CGFloat)width {
    if (feedModel.voteList.count == 0) {
        self.voteViewSize = self.voteGroupSize = CGSizeZero;
        return;
    }
    
    CGFloat contentWidth = width;
    CGFloat totalHeight = 0;
    CGFloat viewWidth = 0, viewHeight = 0;
    
    if (feedModel.isImagePoll) {
        NSInteger numberInRow = 2;
        viewWidth = (contentWidth - (numberInRow - 1) * cellPicSpacing) / numberInRow;
        viewHeight = kVoteImageCellDefaultHeight / kVoteImageCellDefaultWidth * viewWidth;
        
        totalHeight = ceilf((feedModel.voteList.count / (float)numberInRow)) * (viewHeight + cellPicSpacing) - cellPicSpacing;
    } else {
        viewWidth = contentWidth;
        viewHeight = kVoteNoImageCellHeight;
        
        totalHeight = feedModel.voteList.count * (viewHeight + cellPaddingY) - cellPaddingY;
    }
    
    totalHeight += kPollInfoHeight;
    
    if (!feedModel.hasPolled && !feedModel.expiredPoll && !feedModel.isMyPoll) {
        totalHeight += kPollInfoHeight;
    }
    
    self.voteViewSize = CGSizeMake(viewWidth, viewHeight);
    self.voteGroupSize = CGSizeMake(contentWidth, totalHeight);
}

- (void)p_layoutArticle:(WLArticalPostModel *)feedModel width:(CGFloat)width {
    self.articleSize = CGSizeMake(width, cellArticleHeight);
}

- (void)p_layoutRetweeted:(WLForwardPost *)feedModel {
    CGFloat height = 0;
    
    [self p_layoutRetweetedText:feedModel.rootPost];
    height += (self.retweetedTextHeight + cellPaddingY);
    
    if (feedModel.rootPost.type == WELIKE_POST_TYPE_PIC) {
        [self p_layoutPictures:(WLPicPost *)feedModel.rootPost width:cellContentWidth];
        height += (self.picGroupSize.height + cellPaddingY);
    } else if (feedModel.rootPost.type == WELIKE_POST_TYPE_VIDEO) {
        [self p_layoutVideo:(WLVideoPost *)feedModel.rootPost width:cellContentWidth];
        height += (self.videoSize.height + cellPaddingY);
    } else if (feedModel.rootPost.type == WELIKE_POST_TYPE_LINK) {
        self.cardSize = CGSizeMake(cellContentWidth, cellCardHeight);
        height += (self.cardSize.height + cellPaddingY);
    } else if (feedModel.rootPost.type == WELIKE_POST_TYPE_POLL) {
        [self p_layoutPoll:(WLPollPost *)feedModel.rootPost width:cellContentWidth];
        height += (self.voteGroupSize.height);
    } else if (feedModel.rootPost.type ==WELIKE_POST_TYPE_ARTICAL) {
        [self p_layoutArticle:(WLArticalPostModel *)feedModel.rootPost width:cellContentWidth];
        height += (self.articleSize.height);
    }
    
    self.retweetedViewHeight = height + cellPaddingY;
}

- (void)p_layoutRetweetedText:(WLPostBase *)feedModel {
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@", feedModel.nickName] attributes:@{NSForegroundColorAttributeName: kClickableTextColor}];
//
//    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@":%@", feedModel.richContent.text]
//                                                                    attributes:@{NSForegroundColorAttributeName: kBodyFontColor}]];
//
//    [attrStr addAttributes:@{NSFontAttributeName: cellBodyFont} range:NSMakeRange(0, attrStr.string.length)];
//
//    CGFloat height = [attrStr boundingRectWithSize:CGSizeMake(cellContentWidth, kScreenHeight)
//                                           options:NSStringDrawingUsesLineFragmentOrigin
//                                           context:nil].size.height;
//    self.retweetedTextHeight = height;
//    self.retweetedText = attrStr;
    
    self.retweetedTextHeight = self.rootPostHandledFeedModel.richTextHeight;
}

@end
