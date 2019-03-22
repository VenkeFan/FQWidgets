//
//  WLTextLinePositionModifier.h
//  welike
//
//  Created by gyb on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYTextLayout.h"

@interface WLTextLinePositionModifier : NSObject<YYTextLinePositionModifier>
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) CGFloat lineHeightMultiple;

- (CGFloat)heightForLineCount:(NSUInteger)lineCount;

@end
