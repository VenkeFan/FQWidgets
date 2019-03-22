//
//  GBTextEditParser.h
//  GBRichLabel
//
//  Created by gyb on 2018/4/19.
//  Copyright © 2018年 gyb. All rights reserved.
//

#import "YYText.h"

@interface WLTextEditParser : NSObject <YYTextParser>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightTextColor;

@end
