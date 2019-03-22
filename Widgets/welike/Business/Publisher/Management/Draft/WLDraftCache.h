//
//  WLDraftCache.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDraft.h"

typedef void(^listAllShowableCompleted) (NSArray *draftList);
typedef void(^countAllShowableCompleted) (NSInteger count);

@interface WLDraftCache : NSObject

- (void)prepare;
- (void)insertOrUpdate:(WLDraftBase *)draft;
- (void)deleteWithId:(NSString *)draftId;
- (void)deleteAll;
- (void)reset;
- (void)listAllShowable:(listAllShowableCompleted)completed;
- (void)countAllShowable:(countAllShowableCompleted)completed;

@end
