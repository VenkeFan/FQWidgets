//
//  WLPublishTaskManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDraft.h"

@protocol WLPublishTaskManagerDelegate <NSObject>

@optional
- (void)onPublishTaskBegin:(NSString *)taskId;
- (void)onPublishTask:(NSString *)taskId process:(CGFloat)process;
- (void)onPublishTask:(NSString *)taskId end:(NSInteger)errCode;

@end

@interface WLPublishTaskManager : NSObject

- (void)registerDelegate:(id<WLPublishTaskManagerDelegate>)delegate;
- (void)unregister:(id<WLPublishTaskManagerDelegate>)delegate;
- (NSString *)postTask:(WLDraftBase *)draft;

//打点用
-(NSString *)postTaskWithTrackInfo:(WLPublishModel *)trackInfo withDraft:(WLDraftBase *)draft;

@end
