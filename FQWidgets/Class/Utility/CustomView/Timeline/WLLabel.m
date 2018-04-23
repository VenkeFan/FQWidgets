//
//  WLLabel.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/20.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLLabel.h"

@interface WLLabel()

@property (nonatomic, strong) CATextLayer *textLayer;

@end

@implementation WLLabel

//- (instancetype)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        self.textLayer.alignmentMode = kCAAlignmentJustified;
//        self.textLayer.truncationMode = kCATruncationEnd;
//        UIFont *font = kBodyFont;
//        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
//        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
//        self.textLayer.font = fontRef;
//        self.textLayer.fontSize = font.pointSize;
//        CGFontRelease(fontRef);
//        
//        self.textLayer.foregroundColor = kBodyFontColor.CGColor;
//        self.textLayer.wrapped = YES;
//    }
//    return self;
//}
//
//+ (Class)layerClass {
//    return [CATextLayer class];
//}
//
//#pragma mark - Setter
//
//- (void)setText:(NSString *)text {
//    self.textLayer.string = text;
//}
//
//#pragma mark - Getter
//
//- (CATextLayer *)textLayer {
//    return (CATextLayer *)self.layer;
//}

@end
