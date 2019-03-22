//
//  WLArticalTextModel.h
//  welike
//
//  Created by gyb on 2019/1/24.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TYTextRender;
@interface WLArticalTextModel : NSObject


@property (strong,nonatomic) TYTextRender *textRender;
@property (assign,nonatomic,readonly) CGFloat richTextHeight; //富文本高度,在数据处理时就已经算好了
@property(strong,nonatomic) UIFont *font;
@property(assign,nonatomic) CGFloat renderWidth;
@property(assign,nonatomic) CGFloat renderHeight;
@property(assign,nonatomic) NSLineBreakMode lineBreakMode;
@property (copy,nonatomic) NSString *content;


@property(strong,nonatomic) NSMutableArray *urlArray;//link数组

-(void)handleRichModel:(NSString *)text;

-(void)calculateHegihtAndAttributedString:(NSString *)text;


@end

NS_ASSUME_NONNULL_END
