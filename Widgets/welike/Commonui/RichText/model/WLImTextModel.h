//
//  WLImTextModel.h
//  welike
//
//  Created by gyb on 2018/5/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TYTextRender;

@interface WLImTextModel : NSObject

@property (strong,nonatomic) TYTextRender *textRender;
@property (assign,nonatomic,readonly) CGFloat richTextHeight; //富文本高度,在数据处理时就已经算好了
@property(strong,nonatomic) UIFont *font;
@property(assign,nonatomic) CGFloat renderWidth;
@property(assign,nonatomic) CGFloat renderHeight;
@property(assign,nonatomic) NSLineBreakMode lineBreakMode;

@property(strong,nonatomic)NSArray *emotionArray;//表情数组

@property(strong,nonatomic)NSArray *urlArray;//link数组

-(void)handleRichModel:(NSString *)text;

@end
