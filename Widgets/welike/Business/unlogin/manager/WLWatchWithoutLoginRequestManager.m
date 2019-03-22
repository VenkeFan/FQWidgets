//
//  WLWatchWithoutLoginRequestManager.m
//  welike
//
//  Created by gyb on 2018/7/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLWatchWithoutLoginRequestManager.h"
#import "WLVerticalRequest.h"
#import "WLVerticalFeedsRequest.h"
#import "WLVerticalFeedsTypeRequest.h"
#import "WLInterestRequest.h"
#import "WLRefreshVerticalFeedList.h"
#import "WLFeedLayout.h"
#import "WLVerticalVideoRequest.h"
#import "WLTrendingPeopleRequest.h"
#import "WLTrendingSearchWordRequest.h"
#import "WLTrendingBannerRequest.h"
#import "WLTrendingTopicsRequest.h"

@interface WLWatchWithoutLoginRequestManager ()

@property (nonatomic, strong) WLVerticalRequest *verticalRequest;

@property (nonatomic, strong) WLVerticalFeedsRequest *verticalFeedsRequest;
@property (nonatomic, strong) NSString *verticalFeedsCursor;

@property (nonatomic, strong) WLVerticalFeedsTypeRequest *verticalFeedsTypeRequest;
//@property (nonatomic, strong) NSString *verticalFeedsTypeCursor;
@property (nonatomic, strong) NSMutableDictionary *verticalFeedsTypeCursorDic;

@property (nonatomic, strong) WLInterestRequest *interestRequest;

@property (nonatomic, strong) WLRefreshVerticalFeedList *refreshVerticalFeedList;


@property (nonatomic, strong) WLVerticalVideoRequest *verticalVideoRequest;
@property (nonatomic, strong) NSString *verticalVideoCursor;


@property (nonatomic, strong) WLTrendingPeopleRequest *trendingPeopleRequest;

@property (nonatomic, strong) WLTrendingSearchWordRequest *trendingSearchWordRequest;

@property (nonatomic, strong) WLTrendingBannerRequest *trendingBannerRequest;

@property (nonatomic, strong) WLTrendingTopicsRequest *trendingTopicsRequest;
@property (nonatomic, strong) NSString *trendingTopicsCursor;


@end


@implementation WLWatchWithoutLoginRequestManager

-(void)listAllVertical:(listVerticalCompleted)complete
{
    if (self.verticalRequest != nil)
    {
        [self.verticalRequest cancel];
        self.verticalRequest = nil;
    }
    
//    __weak typeof(self) weakSelf = self;
    
    self.verticalRequest = [[WLVerticalRequest alloc] init];
    
    [self.verticalRequest requestVerticalFeedsWithPageNum:1 successed:^(NSArray *items) {
       
        if (complete)
        {
            complete(items,ERROR_SUCCESS);
        }
        
    } error:^(NSInteger errorCode) {
        if (complete)
        {
            complete(nil,errorCode);
        }
    }];
}

-(void)listForMeFeedsWithResult:(listVerticalFeedsCompleted)complete isRefreshFromTop:(BOOL)flag
{
//    NSLog(@"===========请求了");
    if (self.verticalFeedsRequest != nil)
    {
        [self.verticalFeedsRequest cancel];
        self.verticalFeedsRequest = nil;
    }
    
    //下拉刷新,则置为空
    if (flag)
    {
        self.verticalFeedsCursor = nil;
    }
    
     __weak typeof(self) weakSelf = self;
    
    self.verticalFeedsRequest = [[WLVerticalFeedsRequest alloc] init];
    
    NSArray *array = [self selectedInterests];
    
    [self.verticalFeedsRequest requestVerticalFeedsWithCursor:self.verticalFeedsCursor interests:array successed:^(NSArray *feeds, NSString *cursor) {
        

        if (cursor.length > 0)
        {
            weakSelf.verticalFeedsCursor = cursor;
        }
        
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        NSArray *feedLayouts = [weakSelf convertPostListToLayoutModelList:feeds];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                
                complete(feedLayouts, last, ERROR_SUCCESS);
                
            }
        });
        
        
    } error:^(NSInteger errorCode) {
     
//          NSLog(@"结束了1==========");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
        
    }];
}

-(void)listVerticalFeedsWithinterestId:(NSString *)interestId Result:(listVerticalFeedsCompleted)complete isRefreshFromTop:(BOOL)flag
{
    if (self.verticalFeedsTypeRequest != nil)
    {
        [self.verticalFeedsTypeRequest cancel];
        self.verticalFeedsTypeRequest = nil;
    }
    
    if (!self.verticalFeedsTypeCursorDic)
    {
        self.verticalFeedsTypeCursorDic = [[NSMutableDictionary alloc] init];
    }
    
    NSString *lastCursor;
    
    if (flag) //下拉刷新,则置为空
    {
        lastCursor = nil;
    }
    else //非下拉刷新,则拿出interestId对应的cursor
    {
        lastCursor = [self.verticalFeedsTypeCursorDic objectForKey:interestId];
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.verticalFeedsTypeRequest = [[WLVerticalFeedsTypeRequest alloc] init];
    
    [self.verticalFeedsTypeRequest requestVerticalFeedsWithCursor:lastCursor interestId:interestId successed:^(NSArray *feeds, NSString *cursor) {
        
        if (cursor.length > 0)
        {
            [weakSelf.verticalFeedsTypeCursorDic setObject:cursor forKey:interestId];
        }
        
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        NSArray *feedLayouts = [weakSelf convertPostListToLayoutModelList:feeds];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(feedLayouts, last, ERROR_SUCCESS);
                
            }
        });
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
    }];
}

-(void)listInterest:(listVerticalCompleted)complete
{
    if (self.interestRequest != nil)
    {
        [self.interestRequest cancel];
        self.interestRequest = nil;
    }

    
    self.interestRequest = [[WLInterestRequest alloc] init];
    
    [self.interestRequest requestInterest:^(NSArray *feeds) {
        
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(feeds,ERROR_SUCCESS);

            }
        });
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, errorCode);
            }
        });
    }];
}

-(void)refreshPostCache:(listVerticalCompleted)complete
{
    if (self.refreshVerticalFeedList != nil)
    {
        [self.refreshVerticalFeedList cancel];
        self.refreshVerticalFeedList = nil;
    }
    
    self.refreshVerticalFeedList = [[WLRefreshVerticalFeedList alloc] init];
    
    [self.refreshVerticalFeedList RefreshVerticalFeedList:^{
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, errorCode);
            }
        });
    }];
}

-(void)listVideoTag:(listVerticalFeedsCompleted)complete isRefreshFromTop:(BOOL)flag
{
    if (self.verticalVideoRequest != nil)
    {
        [self.verticalVideoRequest cancel];
        self.verticalVideoRequest = nil;
    }
    
    if (flag) //下拉刷新,则置为空
    {
        _verticalVideoCursor = nil;
    }
   

    __weak typeof(self) weakSelf = self;
    NSArray *array = [self selectedInterests];
    self.verticalVideoRequest = [[WLVerticalVideoRequest alloc] init];
    
    [self.verticalVideoRequest requestVerticalVideoFeedsWithCursor:_verticalVideoCursor interests:array successed:^(NSArray *feeds, NSString *cursor) {
        if (cursor.length > 0)
        {
            weakSelf.verticalVideoCursor = cursor;
        }
        
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        NSArray *feedLayouts = [weakSelf convertPostListToLayoutModelList:feeds];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(feedLayouts, last, ERROR_SUCCESS);
                
            }
        });
        
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
        
    }];
}

-(void)listTrendingUsers:(listTrendingUserModelCompleted)complete
{
    if (self.trendingPeopleRequest != nil)
    {
        [self.trendingPeopleRequest cancel];
        self.trendingPeopleRequest = nil;
    }
    
    self.trendingPeopleRequest = [[WLTrendingPeopleRequest alloc] init];
    
    [self.trendingPeopleRequest requestTrendingUsers:^(WLTrendingUserModel *model, NSString *forwardUrl) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(model, forwardUrl, ERROR_SUCCESS);
            }
        });
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, nil, errorCode);
            }
        });
    }];
}

-(void)listTrendingSearchKeys:(listVerticalCompleted)complete
{
    if (self.trendingSearchWordRequest != nil)
    {
        [self.trendingSearchWordRequest cancel];
        self.trendingSearchWordRequest = nil;
    }
    
    self.trendingSearchWordRequest = [[WLTrendingSearchWordRequest alloc] init];
    
    [self.trendingSearchWordRequest trendingSearchKeyWordList:^(NSArray *items) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(items,ERROR_SUCCESS);
            }
        });
        
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, errorCode);
            }
        });
    }];
}


//免登陆banner
-(void)listUnloginBanner:(listVerticalCompleted)complete
{
    if (self.trendingBannerRequest != nil)
    {
        [self.trendingBannerRequest cancel];
        self.trendingBannerRequest = nil;
    }
    
    self.trendingBannerRequest = [[WLTrendingBannerRequest alloc] init];
    
    [self.trendingBannerRequest trendingBannerList:^(NSArray *items) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(items,ERROR_SUCCESS);
            }
        });
        
    } error:^(NSInteger errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, errorCode);
            }
        });
    }];
}


//免登陆热门topic
-(void)listTrendingTopics:(listVerticalFeedsCompleted)complete  isRefreshFromTop:(BOOL)flag
{
    if (self.trendingTopicsRequest != nil)
    {
        [self.trendingTopicsRequest cancel];
        self.trendingTopicsRequest = nil;
    }
    
    
    if (flag) //下拉刷新,则置为空
    {
        _trendingTopicsCursor = nil;
    }
    
    
    __weak typeof(self) weakSelf = self;

    self.trendingTopicsRequest = [[WLTrendingTopicsRequest alloc] init];
 
    [self.trendingTopicsRequest trendingTopicListWithCursor:_trendingTopicsCursor success:^(NSArray *items,NSString *cursor) {
        if (cursor.length > 0)
        {
            weakSelf.verticalVideoCursor = cursor;
        }
        
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(items, last, ERROR_SUCCESS);
                
            }
        });
        
    } error:^(NSInteger errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
    }];
}



#pragma mark - Private

- (NSArray *)convertPostListToLayoutModelList:(NSArray *)feeds
{
    NSMutableArray *feedModels = [NSMutableArray arrayWithCapacity:[feeds count]];
    for (NSInteger i = 0; i < [feeds count]; i++) {
        WLPostBase *feed = [feeds objectAtIndex:i];
        WLFeedLayout *layout = [WLFeedLayout layoutWithFeedModel:feed layoutType:WLFeedLayoutType_TimeLine];
        [feedModels addObject:layout];
    }
    return feedModels;
}

- (NSArray *)selectedInterests {
    NSString *defaultInterestID = @"59";
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:defaultInterestID];
    
    NSArray *selectedItems = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kSelectionInterestsKey];
    if (selectedItems.count > 0) {
        [array addObjectsFromArray:selectedItems];
    }
    return array;
}

@end
