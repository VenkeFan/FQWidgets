//
//  FQHtmlRunDelegate.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/7.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFQHtmlTextAttachmentDefaultWidth           [UIScreen mainScreen].bounds.size.width
#define kFQHtmlTextAttachmentDefaultHeight          130

NS_ASSUME_NONNULL_BEGIN

@interface FQHtmlRunDelegate : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, readonly) CTRunDelegateRef delegateRef;

@end

NS_ASSUME_NONNULL_END
