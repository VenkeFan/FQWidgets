//
//  WLUserAlbumRequest.m
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLUserAlbumRequest.h"
#import "WLAlbumPicModel.h"

@implementation WLUserAlbumRequest

- (instancetype)initWithUserID:(NSString *)userID {
    if ([[[AppContext getInstance] accountManager] isLogin]) {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/image-attachments", userID] method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/skip/user/%@/image-attachments", userID] method:AFHttpOperationMethodGET];
    }
}

- (void)requsetUserAlbumWithCursor:(NSString *)cursor
                           succeed:(userAlbumSuccessed)succeed
                            failed:(failedBlock)failed {
    [self.params removeAllObjects];
    
    [self.params setObject:@(50) forKey:@"count"];
    if (cursor.length > 0) {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *pictures = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *picturesObj = [resDic objectForKey:@"list"];
            
            if (picturesObj.count > 0) {
                pictures = [NSMutableArray arrayWithCapacity:picturesObj.count];
                
                for (int i = 0; i < picturesObj.count; i++) {
                    WLAlbumPicModel *model = [WLAlbumPicModel parseWithNetworkJson:picturesObj[i]];
                    if (model) {
                        [pictures addObject:model];
                    }
                }
            }
            
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if (succeed) {
                succeed(pictures, cursor);
            }
        } else {
            if (failed) {
                failed(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}

@end
