//
//  FQHtmlHighlight.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/9.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FQHtmlHighlightType) {
    FQHtmlHighlightType_Link,
    FQHtmlHighlightType_Image
};

@interface FQHtmlHighlight : NSObject

@property (nonatomic, assign) FQHtmlHighlightType type;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *imgUrl;

@end