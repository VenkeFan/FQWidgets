//
//  WLCommentDetailManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLCommentDetailManager;

@protocol WLCommentDetailManagerDelegate <NSObject>

- (void)onRefreshCommentDetail:(WLCommentDetailManager *)manager replies:(NSArray *)replies cid:(NSString *)cid last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveCommentDetailHis:(WLCommentDetailManager *)manager replies:(NSArray *)replies cid:(NSString *)cid last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLCommentDetailManager : NSObject

@property (nonatomic, weak) id<WLCommentDetailManagerDelegate> delegate;

- (void)tryRefreshWithMainCid:(NSString *)mainCid;
- (void)tryHisWithMainCid:(NSString *)mainCid;

@end
