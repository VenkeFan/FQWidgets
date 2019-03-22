//
//  WLArticalView.m
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalView.h"
#import "WLArticalPostModel.h"
#import "WLRichItem.h"
#import "WLArticalTextModel.h"
#import "TYLabel.h"
#import "UIImageView+WebCache.h"
#import "WLArticalHeaderView.h"
#import "WLArticalBottomView.h"
#import "WLWebViewController.h"

#define PlayerViewTag 10000


@interface WLArticalView ()<TYLabelDelegate>
{
   
    
    
}

@end


@implementation WLArticalView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
       
        articalHeaderView = [[WLArticalHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        
        [self addSubview:articalHeaderView];

        articalBottomView = [[WLArticalBottomView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 114)];
        
//        articalBottomView.backgroundColor = [UIColor orangeColor];
        
        [self addSubview:articalBottomView];
        
        
    }
    return self;
}


-(void)setPostBase:(WLArticalPostModel *)postBase
{
    _postBase = postBase;
    
    articalHeaderView.postBase = postBase;
    articalBottomView.postBase = postBase;
    
    
    
    
    
    //对数据进行处理,对link进行标记
    NSMutableArray *contentArray = [NSMutableArray arrayWithArray:[_postBase.content componentsSeparatedByString:@"🖼"]];
    NSMutableArray *picItems = [[NSMutableArray alloc] initWithCapacity:0];
     NSMutableArray *linkItems = [[NSMutableArray alloc] initWithCapacity:0];
     NSMutableArray *videoItems = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *allItems = [[NSMutableArray alloc] initWithCapacity:0];
    allControls = [[NSMutableArray alloc] initWithCapacity:0];
    _onlyPicItems = [[NSMutableArray alloc] initWithCapacity:0];
    contentHeight = 0; //文本高度
    
    //对连接进行处理
    for (int i = 0; i < _postBase.attachments.count; i++)
    {
        WLRichItem *item = _postBase.attachments[i];
        
        if ([item.type isEqualToString:WLRICH_TYPE_LINK])
        {
            [linkItems addObject:item];
        }
    }
    
    
    if (linkItems.count > 0)
    {
        for (int i = 0; i < linkItems.count; i++)
        {
            WLRichItem *item = linkItems[i];
            
            if (item.title.length > 0)
            {
                if (item.index + item.length <= _postBase.content.length)
                {
                    _postBase.content = [_postBase.content stringByReplacingCharactersInRange:NSMakeRange(item.index, item.length) withString:item.title];
                    
                }
                
                NSInteger chazhi = item.title.length - item.length;
                
                item.length = item.title.length;
                
                for (int j = 0; j < _postBase.attachments.count; j++)
                {
                    WLRichItem *otherItem = _postBase.attachments[j];
                    if (otherItem.index > item.index)
                    {
                        otherItem.index += chazhi;
                    }
                }
            }
            else
            {
//                if (item.display.length > 0)
//                {
//                    if (item.index + item.length <= _postBase.content.length)
//                    {
//                        _postBase.content = [_postBase.content stringByReplacingCharactersInRange:NSMakeRange(item.index, item.length) withString:item.display];
//                    }
//
//                    NSInteger chazhi = item.display.length - item.length;
//
//                    item.length = item.display.length;
//
//                    for (int j = 0; j < _postBase.attachments.count; j++)
//                    {
//                        WLRichItem *otherItem = _postBase.attachments[j];
//                        if (otherItem.index > item.index)
//                        {
//                            otherItem.index += chazhi;
//                        }
//                    }
//                }
//                else
                {
                    //不处理
                }
            }
        }
    }
    
    
    
    
    
    //拿到所有图
    for (int i = 0; i < _postBase.attachments.count; i++)
    {
        WLRichItem *item = _postBase.attachments[i];
        if ([item.type isEqualToString:WLRICH_TYPE_ARTICLE_IMAGE])// || [item.type isEqualToString:@"VIDEO"])
        {
            [picItems addObject:item];
        }
        
        if ([item.type isEqualToString:@"VIDEO"])
        {
            [videoItems addObject:item];
        }
    }

    NSUInteger allNum = picItems.count + contentArray.count;
    NSMutableArray *tempAttachment = [NSMutableArray arrayWithArray:picItems];
    NSMutableArray *tempContentArray = [NSMutableArray arrayWithArray:contentArray];
    
    for(NSUInteger z = 0; z < allNum; z++)
    {
        WLRichItem *item = tempAttachment.lastObject;
        NSString *content = tempContentArray.lastObject;
        
        if (allItems.count > 0)
        {
            id firstObj = allItems.firstObject;
            if ([firstObj isKindOfClass:[WLRichItem class]])
            {
                [allItems insertObject:content atIndex:0];
                [tempContentArray removeLastObject];
            }
            else{
                [allItems insertObject:item atIndex:0];
                [tempAttachment removeLastObject];
            }
        }
        else
        {
            if (item.index == _postBase.content.length + 1)
            {
                [allItems addObject:item];
                [tempAttachment removeLastObject];
            }
            else
            {
                [allItems insertObject:content atIndex:0];
                [tempContentArray removeLastObject];
            }
        }
    }
    
    if (videoItems.count > 0) //通常只有一个
    {
        [allItems addObject:videoItems.firstObject];
    }
    
    //UI
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        NSInteger currentIndex = 0;
        NSInteger currentEnd = 0;
        
        for (int i = 0; i < [allItems count]; i++)
        {
            id content = allItems[i];
            
            if ([content isKindOfClass:[NSString class]])
            {
                NSString *contentStr = content;
                
                currentIndex = currentIndex;
                currentEnd = currentIndex + contentStr.length;
                
                WLArticalTextModel *articalTextModel = [[WLArticalTextModel alloc] init];
                articalTextModel.content = contentStr;
                articalTextModel.font = kRegularFont(14);
                articalTextModel.renderWidth = kScreenWidth - 24;
                articalTextModel.lineBreakMode = NSLineBreakByCharWrapping;
                [articalTextModel handleRichModel:contentStr];
                
                for (int i = 0; i < self->_postBase.attachments.count; i++)
                {
                    WLRichItem *item = self->_postBase.attachments[i];
                    
                    if ([item.type isEqualToString:WLRICH_TYPE_LINK] && item.index >= currentIndex && item.index + item.length <= currentEnd)
                    {
                        [articalTextModel.urlArray addObject:item];
                    }
                }
                
                [articalTextModel calculateHegihtAndAttributedString:contentStr];
                self->contentHeight += articalTextModel.richTextHeight;
              
                [allItems replaceObjectAtIndex:i withObject:articalTextModel];
            }
        }
        
        //NSLog(@"文本高度%f",self->contentHeight);
        
        
        //图片和视频高度
        CGFloat picHeight = (picItems.count + videoItems.count) * ((9*kScreenWidth)/16.0 + 20);
        
        
        //NSLog(@"最终高度%f",self->contentHeight + picHeight);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.height = self->contentHeight + picHeight;
            
            if (self->allControls.count > 0)
            {
                [self updateAllControl];
            }
            else
            {
                CGFloat currentHeight = self->articalHeaderView.bottom;
                
                for (int i = 0; i < allItems.count; i++)
                {
                    id objItem = allItems[i];
                    
                    if ([objItem isKindOfClass:[WLArticalTextModel class]])
                    {
                        WLArticalTextModel *articalTextModel = objItem;
                        
                        TYLabel *richLabel = [[TYLabel alloc] initWithFrame:CGRectMake(12, currentHeight, kScreenWidth - 24, articalTextModel.richTextHeight)];
//                        richLabel.backgroundColor = [UIColor greenColor];
                        //richLabel.textColor = [UIColor blueColor];//RGBCOLOR(66, 61, 45);
                        //需要异步绘制优化
                        richLabel.delegate = self;
                        
                        [richLabel setTextRender:articalTextModel.textRender];
                        [self->allControls addObject:richLabel];
                        [self addSubview:richLabel];
                        
                        currentHeight += richLabel.height;
                        
                        [self updateAllControl];
                        
                    }
                    else //图片
                    {
                        //                        NSLog(@"pic---:%d",i);
                        WLRichItem *item = objItem;
                        UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, currentHeight + 10, kScreenWidth, (9*kScreenWidth)/16.0)];//[UIButton buttonWithType:UIButtonTypeCustom];
                        picView.backgroundColor = kDefaultThumbBgColor;
                       // picBtn.frame = CGRectMake(0, currentHeight + 10, kScreenWidth, (9*kScreenWidth)/16.0);
                        picView.contentMode = UIViewContentModeScaleAspectFit;
                        //picView.tag = 10 + i;
                        picView.userInteractionEnabled = YES;
                        //[picView addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewTap:)];
                        [picView addGestureRecognizer:tap];
                        [self addSubview:picView];
                        [self->allControls addObject:picView];
                       
                        picView.tag = self->_onlyPicItems.count + 10;
                        [self->_onlyPicItems addObject:picView];
                        
                        NSString *thumbUrlStr;
                        
                        if ([item.type isEqualToString:WLRICH_TYPE_ARTICLE_VIDEO])
                        {
                            UIImageView *playFlagView = [[UIImageView alloc] initWithFrame:CGRectMake((picView.width - 56)/2.0, (picView.height - 56)/2.0, 56, 56)];
                            playFlagView.tag = PlayerViewTag - 1;
                            playFlagView.image = [AppContext getImageForKey:@"feed_play"];
                         
                            [picView addSubview:playFlagView];
                            thumbUrlStr = item.icon;
                            
                            picView.tag = PlayerViewTag;
                        }
                        else
                        {
                            thumbUrlStr = item.source;
                        }
                        
                        if (thumbUrlStr.length > 0)
                        {
                            [picView sd_setImageWithURL:[NSURL URLWithString:thumbUrlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                
                                //重设图片大小和位置
                                if (image.size.width < kScreenWidth)
                                {
                                    picView.frame = CGRectMake((kScreenWidth - image.size.width)/2.0, currentHeight, image.size.width, image.size.height);
                                }
                                else
                                {
                                    picView.frame = CGRectMake(0, currentHeight, kScreenWidth, (image.size.height*kScreenWidth)/image.size.width);
                                }
                                
                                UIImageView *playFlagView = [picView viewWithTag:PlayerViewTag - 1];
                                playFlagView.frame = CGRectMake((picView.width - 56)/2.0, (picView.height - 56)/2.0, 56, 56);
                                
                                //更新界面
                                [self updateAllControl];
                                
                            }];
                        }
                        else
                        {
                             [self updateAllControl];
                        }
                    }
                }
            }
        });
    });
}

-(void)updateAllControl
{
    CGFloat currentHeight = articalHeaderView.bottom;
    
    for (int i = 0; i < allControls.count; i++)
    {
        id objItem = allControls[i];
        
        if ([objItem isKindOfClass:[TYLabel class]])
        {
            TYLabel *label = objItem;
            
            //如果前一个时label,则不加10,若前面一个是图片,则加10
            if (i == 0)
            {
                label.top = 10 + currentHeight;
            }
            else
            {
                if (![allControls[i - 1] isKindOfClass:[TYLabel class]])
                {
                    label.top = 10 + currentHeight;
                }
                else
                {
                    label.top = currentHeight;
                }
            }
            
            currentHeight = label.bottom;
        }
        else
        {
            UIImageView *thumbView = objItem;
            thumbView.top = 10 + currentHeight;
            currentHeight = thumbView.bottom;
        }
        
    }
    
    self.height = currentHeight + 10 + 114;
    
    articalBottomView.top = self.height - 114;
    
    
    if ([_delegate respondsToSelector:@selector(updateArticalFrame)])
    {
        [_delegate updateArticalFrame];
    }
}

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight
{
    //NSLog(@"%@",textHighlight.userInfo);
    
    NSString *urlStr = textHighlight.userInfo[@"LINK"];
    
    if (urlStr.length > 0)
    {
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:urlStr];
        [[AppContext currentViewController].navigationController pushViewController:webViewController animated:YES];
    }
}

-(void)imgViewTap:(UITapGestureRecognizer *)gesture
{
    UIImageView *picView = (UIImageView *)gesture.view;
    
    if (picView.tag == PlayerViewTag)
    {
        if ([_delegate  respondsToSelector:@selector(tapVideo)])
        {
            [_delegate tapVideo];
        }
    }
    else
    {
        NSInteger indexNum = picView.tag - 10;
        
        if ([_delegate  respondsToSelector:@selector(tapImage:)])
        {
            [_delegate tapImage:indexNum];
        }
    }
}




@end
