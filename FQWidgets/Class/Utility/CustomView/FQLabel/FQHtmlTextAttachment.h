//
//  FQHtmlTextAttachment.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/7.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const FQHtmlTextAttachmentToken;

@interface FQHtmlTextAttachment : NSObject

+ (UIImage *)placeholder;

@property (nonatomic, strong) id content;
@property (nonatomic, copy) NSString *imgUrl;

@end
