//
//  WLUserAlbumManager.m
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLUserAlbumManager.h"
#import "WLUserAlbumRequest.h"

@interface WLUserAlbumManager ()

@property (nonatomic, strong) WLUserAlbumRequest *request;
@property (nonatomic, copy, readwrite) NSString *userID;
@property (nonatomic, copy) NSString *cursor;

@end

@implementation WLUserAlbumManager

- (void)refreshAlbumsWithUserID:(NSString *)userID {
    self.userID = userID;
    if (self.userID.length == 0) {
        return;
    }
    
    if (_request) {
        return;
    }
    
    _cursor = nil;
    __weak typeof(self) weakSelf = self;
    _request = [[WLUserAlbumRequest alloc] initWithUserID:userID];
    [_request requsetUserAlbumWithCursor:_cursor
                                 succeed:^(NSArray *pictures, NSString *cursor) {
                                     weakSelf.request = nil;
                                     
                                     weakSelf.cursor = cursor;
                                     BOOL last = [weakSelf.cursor length] == 0;
                                     
                                     if ([weakSelf.delegate respondsToSelector:@selector(albumManagerRefresh:pictures:last:errCode:)]) {
                                         [weakSelf.delegate albumManagerRefresh:weakSelf pictures:pictures last:last errCode:ERROR_SUCCESS];
                                     }
                                 }
                                  failed:^(NSInteger errorCode) {
                                      weakSelf.request = nil;
                                      
                                      if ([weakSelf.delegate respondsToSelector:@selector(albumManagerRefresh:pictures:last:errCode:)]) {
                                          [weakSelf.delegate albumManagerRefresh:weakSelf pictures:nil last:NO errCode:errorCode];
                                      }
                                  }];
}

- (void)loadMoreAlbums {
    if (self.userID.length == 0) {
        return;
    }
    
    if (_request) {
        return;
    }
    
    if (_cursor.length != 0) {
        __weak typeof(self) weakSelf = self;
        _request = [[WLUserAlbumRequest alloc] initWithUserID:self.userID];
        [_request requsetUserAlbumWithCursor:_cursor
                                  succeed:^(NSArray *pictures, NSString *cursor) {
                                      weakSelf.request = nil;
                                      
                                      weakSelf.cursor = cursor;
                                      BOOL last = [weakSelf.cursor length] == 0;
                                      
                                      if ([weakSelf.delegate respondsToSelector:@selector(albumManagerMore:pictures:last:errCode:)]) {
                                          [weakSelf.delegate albumManagerMore:weakSelf pictures:pictures last:last errCode:ERROR_SUCCESS];
                                      }
                                  }
                                      failed:^(NSInteger errorCode) {
                                          weakSelf.request = nil;
                                          
                                          if ([weakSelf.delegate respondsToSelector:@selector(albumManagerMore:pictures:last:errCode:)]) {
                                              [weakSelf.delegate albumManagerMore:weakSelf pictures:nil last:NO errCode:errorCode];
                                          }
                                      }];
    } else {
        if ([self.delegate respondsToSelector:@selector(albumManagerMore:pictures:last:errCode:)]) {
            [self.delegate albumManagerMore:self pictures:nil last:YES errCode:ERROR_SUCCESS];
        }
    }
}

@end
