//
//  WLRichContent.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLHandledFeedModel;

@interface WLRichContent : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, strong) NSArray *richItemList;

- (WLRichContent *)copy;
- (NSArray *)copyRichItemList;
- (NSArray *)convertRichItemListToJSON;
+ (NSArray *)convertJSONToRichItemList:(NSArray *)jsonArr;

@end
