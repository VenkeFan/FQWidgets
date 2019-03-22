//
//  WLDraftManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLDraftBase;

typedef void(^listAllCompleted) (NSArray *draftList);
typedef void(^countAllCompleted) (NSInteger count);

@interface WLDraftManager : NSObject

- (void)prepare;
- (void)insertOrUpdate:(WLDraftBase *)draft;
- (void)resetUncompletedDraft:(WLDraftBase *)draft;
- (void)deleteDraftWithId:(NSString *)draftId;
- (void)clearAll;
- (void)listAll:(listAllCompleted)completed;
- (void)countAll:(countAllCompleted)completed;
- (void)reset;

@end
