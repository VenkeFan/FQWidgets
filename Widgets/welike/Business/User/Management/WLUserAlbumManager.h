//
//  WLUserAlbumManager.h
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLUserAlbumManager;

@protocol WLUserAlbumManagerDelegate <NSObject>

- (void)albumManagerRefresh:(WLUserAlbumManager *)manager
                   pictures:(NSArray *)pictures
                       last:(BOOL)last
                    errCode:(NSInteger)errCode;
- (void)albumManagerMore:(WLUserAlbumManager *)manager
                pictures:(NSArray *)pictures
                    last:(BOOL)last
                 errCode:(NSInteger)errCode;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLUserAlbumManager : NSObject

@property (nonatomic, weak) id<WLUserAlbumManagerDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *userID;

- (void)refreshAlbumsWithUserID:(NSString *)userID;
- (void)loadMoreAlbums;

@end

NS_ASSUME_NONNULL_END
