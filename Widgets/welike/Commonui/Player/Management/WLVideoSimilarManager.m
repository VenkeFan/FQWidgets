//
//  WLVideoSimilarManager.m
//  welike
//
//  Created by fan qi on 2018/8/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVideoSimilarManager.h"
#import "WLVideoSimilarRequest.h"

@interface WLVideoSimilarManager ()

@property (nonatomic, strong) WLVideoSimilarRequest *request;
@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) NSString *cursor;

@end

@implementation WLVideoSimilarManager

- (instancetype)initWithPostID:(NSString *)postID {
    if (self = [super init]) {
        _postID = [postID copy];
    }
    return self;
}

- (void)tryRefreshVideos {
    if (_request != nil) {
        return;
    }
    _cursor = nil;
    
    __weak typeof(self) weakSelf = self;
    _request = [[WLVideoSimilarRequest alloc] initWithPostID:_postID];
    [_request tryVideoSimilarWithCursor:_cursor
                              successed:^(NSArray *videos, NSString *cursor) {
                                  weakSelf.request = nil;
                                  
                                  weakSelf.cursor = cursor;
                                  BOOL last = [weakSelf.cursor length] == 0;
                                  
                                  if ([weakSelf.delegate respondsToSelector:@selector(onRefreshManager:videos:last:errCode:)]) {
                                      [weakSelf.delegate onRefreshManager:weakSelf videos:videos last:last errCode:ERROR_SUCCESS];
                                  }
                              }
                                  error:^(NSInteger errorCode) {
                                      weakSelf.request = nil;
                                      
                                      if ([weakSelf.delegate respondsToSelector:@selector(onRefreshManager:videos:last:errCode:)]) {
                                          [weakSelf.delegate onRefreshManager:weakSelf videos:nil last:NO errCode:errorCode];
                                      }
                                  }];;
}

- (void)tryHisVideos {
    if (_request != nil) {
        return;
    }
    
    if (_cursor.length != 0) {
        __weak typeof(self) weakSelf = self;
        _request = [[WLVideoSimilarRequest alloc] initWithPostID:_postID];
        [_request tryVideoSimilarWithCursor:_cursor
                                  successed:^(NSArray *videos, NSString *cursor) {
                                      weakSelf.request = nil;
                                      
                                      weakSelf.cursor = cursor;
                                      BOOL last = [weakSelf.cursor length] == 0;
                                      
                                      if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisManager:videos:last:errCode:)]) {
                                          [weakSelf.delegate onReceiveHisManager:weakSelf videos:videos last:last errCode:ERROR_SUCCESS];
                                      }
                                  }
                                      error:^(NSInteger errorCode) {
                                          weakSelf.request = nil;
                                          
                                          if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisManager:videos:last:errCode:)]) {
                                              [weakSelf.delegate onReceiveHisManager:weakSelf videos:nil last:NO errCode:errorCode];
                                          }
                                      }];
    } else {
        if ([self.delegate respondsToSelector:@selector(onReceiveHisManager:videos:last:errCode:)]) {
            [self.delegate onReceiveHisManager:self videos:nil last:YES errCode:ERROR_SUCCESS];
        }
    }
}

@end
