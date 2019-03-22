//
//  WLHandledFeedModel.h
//  GBRichLabel
//
//  Created by gyb on 2018/4/16.
//  Copyright © 2018年 gyb. All rights reserved.
//  feed流富文本数据处理model

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WLPostBase.h"

@class TYTextRender;
@class WLRichContent;

@interface WLHandledFeedModel : NSObject


@property (strong,nonatomic) TYTextRender *textRender;

@property (assign,nonatomic,readonly) CGFloat richTextHeight; //富文本高度,在数据处理时就已经算好了

@property(strong,nonatomic) UIFont *font;
@property(assign,nonatomic) CGFloat renderWidth;
@property(assign,nonatomic) CGFloat renderHeight; //此属性设为0时,可以得到正确的高度,若设为非0,则为固定高度
@property(assign,nonatomic) NSLineBreakMode lineBreakMode;
@property(assign,nonatomic) NSInteger maxLineNum; //如果不需要的话.赋值0,表示不限行数

@property(strong,nonatomic)NSArray *emotionArray;//表情数组
@property(strong,nonatomic)NSArray *atPersonArray;//at
@property(strong,nonatomic)NSArray *urlArray;//link数组
@property(strong,nonatomic)NSArray *topicArray;//话题数组
@property(strong,nonatomic)NSArray *articleArray;//artical数组

@property(assign,nonatomic) BOOL isSummaryDisplay;//YES 则在需要时显示summary //NO则全部显示
@property(strong,nonatomic) UIColor *textColor;

@property (assign,nonatomic) NSRange rangeOfSpecial;

//导航
@property (strong,nonatomic) RDLocation *location;



-(void)handleRichModel:(WLRichContent *)richContent;

@end
