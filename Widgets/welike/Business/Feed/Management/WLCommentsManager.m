//
//  WLCommentsManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentsManager.h"
#import "WLCreatedCommentsProvider.h"
#import "WLHotCommentsProvider.h"
#import "WLCommentLayout.h"

@interface WLCommentsManager () <WLCommentsProviderDelegate>

@property (nonatomic, strong) id<WLCommentsProvider> provider;

- (NSArray *)convertCommentListToLayoutModelList:(NSArray *)comments;

@end

@implementation WLCommentsManager

- (void)setDataSourceProvider:(id<WLCommentsProvider>)provider
{
    if (self.provider != nil)
    {
        [self.provider stop];
        [self.provider setListener:nil];
    }
    self.provider = provider;
    [self.provider setListener:self];
}

- (void)tryRefreshCommentsForPid:(NSString *)pid
{
    if (self.provider != nil)
    {
        [self.provider tryRefreshCommentsForPid:pid];
    }
}

- (void)tryHisCommentsForPid:(NSString *)pid
{
    if (self.provider != nil)
    {
        [self.provider tryHisCommentsForPid:pid];
    }
}

#pragma mark WLCommentsProviderDelegate methods
- (void)onRefreshCommentsProvider:(id<WLCommentsProvider>)provider comments:(NSArray *)comments last:(BOOL)last error:(NSInteger)error
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *commentModels = [weakSelf convertCommentListToLayoutModelList:comments];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onRefreshManager:comments:last:errCode:)])
            {
                [weakSelf.delegate onRefreshManager:weakSelf comments:commentModels last:last errCode:error];
            }
        });
    });
}

- (void)onReceiveHisCommentsProvider:(id<WLCommentsProvider>)provider comments:(NSArray *)comments last:(BOOL)last error:(NSInteger)error
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *commentModels = [weakSelf convertCommentListToLayoutModelList:comments];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisManager:comments:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisManager:weakSelf comments:commentModels last:last errCode:error];
            }
        });
    });
}

#pragma mark private methods
- (NSArray *)convertCommentListToLayoutModelList:(NSArray *)comments
{
    NSMutableArray *commentArray = [NSMutableArray arrayWithCapacity:[comments count]];
    for (NSInteger i = 0; i < [comments count]; i++) {
        WLCommentLayout *layout = [[WLCommentLayout alloc] initWithComment:[comments objectAtIndex:i]];
        [commentArray addObject:layout];
    }
    return commentArray;
}

@end
