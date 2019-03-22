//
//  WLFoldRichView.m
//  welike
//
//  Created by gyb on 2018/8/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFoldRichView.h"
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
#import "WLWebViewController.h"


@implementation WLFoldRichView

- (id)initWithFrame:(CGRect)frame withMinLineNum:(NSInteger)lineNum
{
    self = [super initWithFrame:frame];
    if (self)
    {
        contentLabel = [[TYLabel  alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100)];
        //contentLabel.textColor = kDescFontColor;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.delegate = self;
        [self addSubview:contentLabel];
         
         _lineNum = lineNum;

    }
    return self;
}


-(void)setContentColor:(UIColor *)contentColor
{
    _contentColor = contentColor;
    
    contentLabel.textColor = contentColor;
}

-(void)setPostBase:(WLPostBase *)postBase
{
    _postBase = postBase;
    
    WLHandledFeedModel  *handledFeedModel = [[WLHandledFeedModel alloc] init];
    handledFeedModel.font = kRegularFont(14);
    handledFeedModel.renderWidth = contentLabel.width;
    handledFeedModel.renderHeight = 0; //此处设为0为动态大小
    handledFeedModel.lineBreakMode = NSLineBreakByTruncatingTail;
    handledFeedModel.maxLineNum = _lineNum;
    handledFeedModel.textColor = [UIColor whiteColor];

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
    contentLabel.height  = handledFeedModel.richTextHeight;
    self.height = contentLabel.height;
    
    //计算最大和最小高度
    [self caculateContentHeight:_postBase];
}

-(void)fold //折叠
{
    _lineNum = 2;
    [self setPostBase:_postBase];
}

-(void)unfold //展开
{
    _lineNum = 10;
    [self setPostBase:_postBase];
}

-(BOOL)canUnfold  //用于判断是否显示折叠按钮
{
    if (maxHeight != minHeight)
    {
        return YES; //能展开
    }
    else
    {
        return NO; //不能展开
    }
}


-(BOOL)isFold 
{
    if (self.height == minHeight)
    {
          return YES; //是折叠
    }
    else{
          return NO; //不是折叠
    }
}


-(void)caculateContentHeight:(WLPostBase *)postBase
{
    WLHandledFeedModel  *handledFeedModelMin = [[WLHandledFeedModel alloc] init];
    handledFeedModelMin.font = kRegularFont(14);
    handledFeedModelMin.renderWidth = contentLabel.width;
    handledFeedModelMin.renderHeight = 0;
    handledFeedModelMin.lineBreakMode = NSLineBreakByTruncatingTail;
    handledFeedModelMin.maxLineNum = 2;
    handledFeedModelMin.textColor = [UIColor whiteColor];
    
    WLHandledFeedModel  *handledFeedModelMax = [[WLHandledFeedModel alloc] init];
    handledFeedModelMax.font = kRegularFont(14);
    handledFeedModelMax.renderWidth = contentLabel.width;
    handledFeedModelMax.renderHeight = 0;
    handledFeedModelMax.lineBreakMode = NSLineBreakByTruncatingTail;
    handledFeedModelMax.maxLineNum = 10;
    handledFeedModelMax.textColor = [UIColor whiteColor];
    

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
        
        [handledFeedModelMax handleRichModel:postContent];
        [handledFeedModelMin handleRichModel:postContent];
    }
    else
    {
        [handledFeedModelMax handleRichModel:postBase.richContent];
        [handledFeedModelMin handleRichModel:postBase.richContent];
    }
    
    maxHeight = handledFeedModelMax.richTextHeight;
    minHeight = handledFeedModelMin.richTextHeight;
}

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight
{
    NSString *key = textHighlight.userInfo.allKeys.firstObject;
   
    if ([key isEqualToString:WLRICH_TYPE_MENTION])
    {
        if ([_delegate respondsToSelector:@selector(clickUser:)]) {
            [_delegate clickUser:textHighlight.userInfo[key]];
        }
    }
    
    if ([key isEqualToString:WLRICH_TYPE_TOPIC])
    {
        if ([_delegate respondsToSelector:@selector(clickTopic:)]) {
            [_delegate clickTopic:textHighlight.userInfo[key]];
        }
    }
    
    if ([key isEqualToString:WLRICH_TYPE_LINK])
    {
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:textHighlight.userInfo[key]];
        [[AppContext rootViewController] pushViewController:webViewController animated:YES];
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:textHighlight.userInfo[key]]];
    }
    
    if ([key isEqualToString:WLRICH_TYPE_LOCATION])
    {
        if ([_delegate respondsToSelector:@selector(clickLoction:)]) {
            [_delegate clickLoction:@""];
        }
    }
}

@end
