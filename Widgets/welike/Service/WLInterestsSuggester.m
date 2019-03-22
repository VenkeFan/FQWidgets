//
//  WLInterestsSuggester.m
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestsSuggester.h"
#import "WLInterestsRequest.h"

@interface WLInterestsSuggester ()

@property (nonatomic, strong) WLInterestsRequest *request;
@property (nonatomic, assign) NSInteger cursorNum;

@end

@implementation WLInterestsSuggester

- (void)refresh
{
    if (self.request != nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.cursorNum = 0;
    self.request = [[WLInterestsRequest alloc] initInterestsRequest];
    [self.request listInterestsWithPageNum:self.cursorNum referrerId:nil successed:^(NSArray *interests, WLReferrerInfo *referrerInfo) {
        weakSelf.request = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshInetrestSuggestions:referrerInfo:errCode:)])
        {
            [weakSelf.delegate onRefreshInetrestSuggestions:interests referrerInfo:referrerInfo errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.request = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshInetrestSuggestions:referrerInfo:errCode:)])
        {
            [weakSelf.delegate onRefreshInetrestSuggestions:nil referrerInfo:nil errCode:errorCode];
        }
    }];
}

- (void)his
{
    if (self.request != nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.cursorNum++;
    self.request = [[WLInterestsRequest alloc] initInterestsRequest];
    [self.request listInterestsWithPageNum:self.cursorNum referrerId:nil successed:^(NSArray *interests, WLReferrerInfo *referrerInfo) {
        weakSelf.request = nil;
        BOOL last;
        if ([interests count] == INTERESTS_NUM_ONE_PAGE)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        if ([weakSelf.delegate respondsToSelector:@selector(onHisInterestSuggestions:last:errCode:)])
        {
            [weakSelf.delegate onHisInterestSuggestions:interests last:last errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.request = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onHisInterestSuggestions:last:errCode:)])
        {
            [weakSelf.delegate onHisInterestSuggestions:nil last:NO errCode:errorCode];
        }
    }];
}

@end
