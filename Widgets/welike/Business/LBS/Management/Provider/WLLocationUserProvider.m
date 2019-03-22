//
//  WLLocationUserProvider.m
//  welike
//
//  Created by gyb on 2018/6/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationUserProvider.h"
#import "WLUsersProviderDelegate.h"
#import "WLLocationPersonsRequest.h"

@interface WLLocationUserProvider ()

@property (nonatomic, strong) WLLocationPersonsRequest *usersRequest;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, weak) id<WLUsersProviderDelegate> delegate;
@property (nonatomic, assign) BOOL isEnd;

@end


@implementation WLLocationUserProvider

- (void)tryRefreshUsersWithKeyId:(NSString *)placeId
{
    if (self.usersRequest != nil) return;
    
    __weak typeof(self) weakSelf = self;
  
    self.pageNo = 0;
    [self.cacheList removeAllObjects];
    self.usersRequest = [[WLLocationPersonsRequest alloc] initLocationPersons:placeId];
    [self.usersRequest locationPersons:_pageNo successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
        
        weakSelf.usersRequest = nil;
        NSArray *list = [weakSelf filterUsers:users];
        
        weakSelf.isEnd = last;
        
        if (last == NO)
        {
            weakSelf.pageNo++;
        }
        
        NSInteger newCount = [weakSelf refreshNewCount:list];
        [weakSelf cacheFirstPage:list];
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshUsersProvider:users:kid:newCount:last:errCode:)])
        {
            [weakSelf.delegate onRefreshUsersProvider:weakSelf users:list kid:placeId newCount:newCount last:last errCode:ERROR_SUCCESS];
        }
        
    } error:^(NSInteger errorCode) {
        weakSelf.usersRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshUsersProvider:users:kid:newCount:last:errCode:)])
        {
            [weakSelf.delegate onRefreshUsersProvider:weakSelf users:nil kid:placeId newCount:0 last:NO errCode:errorCode];
        }
    }];
}

- (void)tryHisUsersWithKeyId:(NSString *)placeId
{
    if (self.usersRequest != nil) return;

    if (self.isEnd == NO )
    {
        __weak typeof(self) weakSelf = self;
        self.usersRequest = [[WLLocationPersonsRequest alloc] initLocationPersons:placeId];
         [self.usersRequest locationPersons:_pageNo successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
            weakSelf.usersRequest = nil;
            NSArray *list = [weakSelf filterUsers:users];
         
             
             if (last == NO)
             {
                 weakSelf.pageNo++;
             }
             

            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisUsersProvider:weakSelf users:list kid:placeId last:last errCode:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.usersRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisUsersProvider:weakSelf users:nil kid:placeId last:NO errCode:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)])
        {
            [self.delegate onReceiveHisUsersProvider:self users:nil kid:placeId last:YES errCode:ERROR_SUCCESS];
        }
    }
}

- (void)setListener:(id<WLUsersProviderDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)stop
{
    if (self.usersRequest != nil)
    {
        [self.usersRequest cancel];
        self.usersRequest = nil;
    }
}

@end
