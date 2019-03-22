//
//  RDResManager.m
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDResManager.h"
//#import "RDStringResourceParser.h"
#import "RDLocalizationManager.h"
#import "LuuUtils.h"

@interface RDResManager () <RDLocalizationManagerDelegate>

@property (nonatomic, strong) NSBundle *imagesBundle;
//@property (nonatomic, strong) RDStringResourceParser *stringResParser;

- (UIImage *)getImageForKey:(NSString *)key withBundle:(NSBundle *)bundle;

@end

@implementation RDResManager

- (id)init
{
    self = [super init];
    if (self)
    {
//        self.stringResParser = [[RDStringResourceParser alloc] init];
        self.imagesBundle = [[NSBundle alloc] initWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"images.bundle"]];
        [[RDLocalizationManager getInstance] registerDelegate:self];
    }
    return self;
}


- (void)dealloc
{
    [[RDLocalizationManager getInstance] unregisterDelegate:self];
}

#pragma mark RDResManager public methods
- (UIImage *)getImageForKey:(NSString *)key
{
    UIImage *image = [self getImageForKey:key withBundle:self.imagesBundle];
    if (image == nil)
    {
        image = [self getImageForKey:key withBundle:[NSBundle mainBundle]];
    }
    
    return image;
}

#pragma mark RDResManager private methods
- (UIImage *)getImageForKey:(NSString *)key withBundle:(NSBundle *)bundle
{
    UIImage *image = nil;
    NSString *useKey = key;
    if ([LuuUtils mainScreenScale] >= 3.0f)
    {
        useKey = [NSString stringWithFormat:@"%@@3x", key];
    }
    NSString *imagePath = [bundle pathForResource:useKey ofType:@"png"];
    if([imagePath length] == 0)
    {
        useKey = [NSString stringWithFormat:@"%@@2x",key];
        imagePath = [bundle pathForResource:useKey ofType:@"png"];
        if([imagePath length] == 0)
        {
            useKey = key;
            imagePath = [bundle pathForResource:useKey ofType:@"png"];
        }
    }
    
    if ([imagePath length] > 0)
    {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return image;
}

//#pragma mark RDLocalizationManagerDelegate methods
//- (void)didChangedLanguage:(NSString *)language
//{
////    [self.stringResParser clearCache];
//}

@end
