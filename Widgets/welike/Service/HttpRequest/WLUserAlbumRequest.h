//
//  WLUserAlbumRequest.h
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^userAlbumSuccessed)(NSArray *pictures, NSString *cursor);

NS_ASSUME_NONNULL_BEGIN

@interface WLUserAlbumRequest : RDBaseRequest

- (instancetype)initWithUserID:(NSString *)userID;
- (void)requsetUserAlbumWithCursor:(NSString *)cursor
                           succeed:(userAlbumSuccessed)succeed
                            failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
