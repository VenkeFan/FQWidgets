//
//  WLUploadStatusStorage.h
//  welike
//
//  Created by 刘斌 on 2018/4/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLUploadStatusStorage : NSObject

- (void)prepare;

- (NSString *)getMultiPartStatus:(NSString *)sign;
- (void)putMultiPartStatus:(NSString *)uploadId forSign:(NSString *)sign;
- (void)removeMultiPartStatusForSign:(NSString *)sign;

@end
