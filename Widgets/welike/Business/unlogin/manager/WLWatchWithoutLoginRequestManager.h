//
//  WLWatchWithoutLoginRequestManager.h
//  welike
//
//  Created by gyb on 2018/7/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTrendingUserModel.h"


typedef void(^listVerticalCompleted) (NSArray *items, NSInteger errCode);

typedef void(^listVerticalFeedsCompleted) (NSArray *items,BOOL isLast, NSInteger errCode);

typedef void(^listTrendingUserModelCompleted) (WLTrendingUserModel *model, NSString *forwardUrl, NSInteger errCode);



@interface WLWatchWithoutLoginRequestManager : NSObject

-(void)listAllVertical:(listVerticalCompleted)complete;

-(void)listForMeFeedsWithResult:(listVerticalFeedsCompleted)complete  isRefreshFromTop:(BOOL)flag;

-(void)listVerticalFeedsWithinterestId:(NSString *)interestId Result:(listVerticalFeedsCompleted)complete isRefreshFromTop:(BOOL)flag;

-(void)listInterest:(listVerticalCompleted)complete;

-(void)listVideoTag:(listVerticalFeedsCompleted)complete isRefreshFromTop:(BOOL)flag;

//当选择完观看的垂类后调用
-(void)refreshPostCache:(listVerticalCompleted)complete;

//热门user
-(void)listTrendingUsers:(listTrendingUserModelCompleted)complete;

//热门key
-(void)listTrendingSearchKeys:(listVerticalCompleted)complete;

//免登陆banner
-(void)listUnloginBanner:(listVerticalCompleted)complete;


//免登陆热门topic
-(void)listTrendingTopics:(listVerticalFeedsCompleted)complete  isRefreshFromTop:(BOOL)flag;

@end
