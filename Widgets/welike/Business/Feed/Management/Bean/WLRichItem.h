//
//  WLRichItem.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WLRICH_TYPE_MENTION            @"MENTION"
#define WLRICH_TYPE_TOPIC              @"TOPIC"
#define WLRICH_TYPE_LINK               @"LINK"
#define WLRICH_TYPE_MORE               @"MORE"
#define WLRICH_TYPE_EMOJI               @"EMOJI"
#define WLRICH_TYPE_LOCATION            @"Location"
#define WLRICH_TYPE_ARTICLE            @"ARTICLE"
#define WLRICH_TYPE_ARTICLE_IMAGE       @"IMAGE"
#define WLRICH_TYPE_ARTICLE_VIDEO       @"VIDEO"



@interface WLRichItem : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *rid;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, copy) NSString *display;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;

+ (WLRichItem *)parseFromJSON:(NSDictionary *)json;
- (WLRichItem *)copy;

@end
