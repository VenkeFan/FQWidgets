//
//  WLPublishCardView.m
//  welike
//
//  Created by gyb on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPublishCardView.h"
#import "TYLabel.h"
#import "WLPostBase.h"
#import "WLPicPost.h"
#import "UIImageView+Extension.h"
#import "WLPicInfo.h"
#import "WLHandledFeedModel.h"
#import "WLForwardPost.h"
#import "TYTextRender.h"
#import "WLLinkPost.h"
#import "WLVideoPost.h"
#import "WLTextParse.h"
#import "WLRichItem.h"

@implementation WLPublishCardView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
         
        thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.5, 63, 63)];
        thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        thumbImageView.clipsToBounds = YES;
        [self addSubview:thumbImageView];
        
        playFlag = [[UIImageView alloc] initWithFrame:CGRectZero];
        playFlag.image = [AppContext getImageForKey:@"common_play"];
        [thumbImageView addSubview:playFlag];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbImageView.right + 10, 5, kScreenWidth - 30 - thumbImageView.width - 20 , 16)];
//        nameLabel.backgroundColor = [UIColor redColor];
        nameLabel.font = kBoldFont(14);
        nameLabel.text = @"";
        nameLabel.textColor = kNameFontColor;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];
        
        contentLabel = [[TYLabel  alloc] initWithFrame:CGRectMake(nameLabel.left, nameLabel.bottom + 3, nameLabel.width, 35)];
        contentLabel.textColor = kDescFontColor;
//        contentLabel.backgroundColor = [UIColor redColor];
        [self addSubview:contentLabel];
        
    
    }
    return self;
}


-(void)setPostBase:(WLPostBase *)postBase
{
    _postBase = postBase;
    
    if (postBase.type == WELIKE_POST_TYPE_FORWARD)
    {
        if ([postBase isKindOfClass:[WLForwardPost class]])
        {
            WLForwardPost *forwardPost = (WLForwardPost *)postBase;

            if (forwardPost.forwardDeleted)
            {
                thumbImageView.image = [AppContext getImageForKey:@"common_placeholder_bad"];
                nameLabel.text = @"";
                
                WLRichContent *deleteContent = [[WLRichContent alloc] init];
                deleteContent.text = [AppContext getStringForKey:@"forward_feed_delete_content" fileName:@"feed"];
                deleteContent.summary =  deleteContent.text;
            
               //  [thumbImageView fq_setImageWithURLString:nil];
              
                    WLHandledFeedModel  *handledFeedModel = [[WLHandledFeedModel alloc] init];
                    handledFeedModel.font = kRegularFont(14);
                    handledFeedModel.renderWidth = contentLabel.width;
                    handledFeedModel.renderHeight = 40;
                    handledFeedModel.lineBreakMode = NSLineBreakByTruncatingTail;
                    handledFeedModel.maxLineNum = 2;
                    handledFeedModel.textColor = kBodyFontColor;
                    [handledFeedModel handleRichModel:deleteContent];
                    
                    [contentLabel setTextRender:handledFeedModel.textRender];
                    
                    contentLabel.height  = handledFeedModel.textRender.textBound.size.height;
            }
            else
            {
                playFlag.frame = CGRectZero;
                
                if ([forwardPost.rootPost isKindOfClass:[WLPicPost class]])
                {
                    WLPicPost *picPost = (WLPicPost *)forwardPost.rootPost;
                    WLPicInfo *picInfo = picPost.picInfoList.firstObject;
                    [picInfo calculatePicThumbnailInfoWithWidth:thumbImageView.width*2];
                    
                    [thumbImageView fq_setImageWithURLString:[picInfo thumbnailPicUrl]];
                    nameLabel.text = [NSString stringWithFormat:@"@%@",picPost.nickName];
                    
                }
                else
                    if ([forwardPost.rootPost isKindOfClass:[WLLinkPost class]])
                    {
                        WLLinkPost *picPost = (WLLinkPost *)forwardPost.rootPost;
                        [thumbImageView fq_setImageWithURLString:[picPost linkThumbUrl]];
                        nameLabel.text = [NSString stringWithFormat:@"@%@",picPost.nickName];
                    }
                    else
                        if ([forwardPost.rootPost isKindOfClass:[WLVideoPost class]])
                        {
                            WLVideoPost *picPost = (WLVideoPost *)forwardPost.rootPost;
                            
                            [thumbImageView fq_setImageWithURLString:[picPost coverUrl]];
                            nameLabel.text = [NSString stringWithFormat:@"@%@",picPost.nickName];
                            
                            playFlag.frame = CGRectMake(0, 0, 24, 24);
                            playFlag.center = CGPointMake(31.5, 31.5);
                        }
                        else
                        {
                            [thumbImageView fq_setImageWithURLString:forwardPost.rootPost.headUrl];
                            nameLabel.text = [NSString stringWithFormat:@"@%@",forwardPost.rootPost.nickName];
                        }
                
                WLHandledFeedModel  *handledFeedModel = [[WLHandledFeedModel alloc] init];
                handledFeedModel.font = kRegularFont(14);
                handledFeedModel.renderWidth = contentLabel.width;
                handledFeedModel.renderHeight = 40;
                handledFeedModel.lineBreakMode = NSLineBreakByTruncatingTail;
                handledFeedModel.maxLineNum = 2;
                 handledFeedModel.textColor = kBodyFontColor;
                
                WLRichContent *contentOfLink = [[WLRichContent alloc] init];
                contentOfLink.richItemList = [forwardPost.rootPost.richContent copyRichItemList];
                contentOfLink.text = [NSString stringWithString:forwardPost.rootPost.richContent.text];
                if (forwardPost.rootPost.richContent.summary.length == 0)
                {
                    contentOfLink.summary =  contentOfLink.text;
                }
                else
                {
                    contentOfLink.summary = [NSString stringWithString:forwardPost.rootPost.richContent.summary];
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
                            if (item.display.length > 0)
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
                    
                    [handledFeedModel handleRichModel:contentOfLink];
                }
                else
                {
                    [handledFeedModel handleRichModel:forwardPost.rootPost.richContent];
                }
                
                
                [contentLabel setTextRender:handledFeedModel.textRender];
                
                contentLabel.height  = handledFeedModel.textRender.textBound.size.height;
            }
        }
    }
    else
    {
         playFlag.frame = CGRectZero;
        if ([postBase isKindOfClass:[WLPicPost class]])
        {
            WLPicPost *picPost = (WLPicPost *)postBase;
            WLPicInfo *picInfo = picPost.picInfoList.firstObject;
            [picInfo calculatePicThumbnailInfoWithWidth:thumbImageView.width*2];
            [thumbImageView fq_setImageWithURLString:[picInfo thumbnailPicUrl]];
            
            nameLabel.text = [NSString stringWithFormat:@"@%@",picPost.nickName];
            
        }
        else
        if ([postBase isKindOfClass:[WLLinkPost class]])
        {
            WLLinkPost *picPost = (WLLinkPost *)postBase;
            [thumbImageView fq_setImageWithURLString:[picPost linkThumbUrl]];
            
            nameLabel.text = [NSString stringWithFormat:@"@%@",picPost.nickName];
        }
        else
            if ([postBase isKindOfClass:[WLVideoPost class]])
            {
                WLVideoPost *picPost = (WLVideoPost *)postBase;
                
                [thumbImageView fq_setImageWithURLString:[picPost coverUrl]];
                nameLabel.text = [NSString stringWithFormat:@"@%@",picPost.nickName];
                
                playFlag.frame = CGRectMake(0, 0, 24, 24);
                playFlag.center = CGPointMake(31.5, 31.5);
                
            }
        else
        {
            [thumbImageView fq_setImageWithURLString:postBase.headUrl];
            nameLabel.text = [NSString stringWithFormat:@"@%@",postBase.nickName];
        }
        
        WLHandledFeedModel  *handledFeedModel = [[WLHandledFeedModel alloc] init];
        handledFeedModel.font = kRegularFont(14);
        handledFeedModel.renderWidth = contentLabel.width;
        handledFeedModel.renderHeight = 40;
        handledFeedModel.lineBreakMode = NSLineBreakByTruncatingTail;
        handledFeedModel.maxLineNum = 2;
        handledFeedModel.textColor = kBodyFontColor;
        WLRichContent *originalContent = postBase.richContent;
        WLRichContent *postContent = [[WLRichContent alloc] init];
        postContent.richItemList = [originalContent copyRichItemList];
        postContent.text = [NSString stringWithString:originalContent.text];
        if (originalContent.summary.length == 0)
        {
            postContent.summary =  postContent.text;
        }
        else
        {
             postContent.summary = [NSString stringWithString:originalContent.summary];
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
            
            [handledFeedModel handleRichModel:postContent];
        }
        else
        {
             [handledFeedModel handleRichModel:postBase.richContent];
        }
        
        [contentLabel setTextRender:handledFeedModel.textRender];
        contentLabel.height  = handledFeedModel.textRender.textBound.size.height;
    }
}




@end
