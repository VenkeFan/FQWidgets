//
//  WLUploadRecord.h
//  welike
//
//  Created by gyb on 2019/1/30.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKKeyValueStore.h"

//本地文件数据库
#define WLFileDBName @"WLFileDB.db"
#define WLUploadFileTable @"WLUploadFileTable"

NS_ASSUME_NONNULL_BEGIN

@interface WLUploadRecord : NSObject

//添加一个记录
+(void)addImageWithIdentifer:(NSString *)idertifer width:(CGFloat)width height:(CGFloat)height imageUrl:(NSString *)urlString;

//删除一个记录
+(void)removeImageWithidertifer:(NSString *)idertifer;

//查询一个已经上传成功了的图片url的记录
+(NSString *)getUploadImageUrlWithidertifer:(NSString *)idertifer;

//仅用于测试
+(NSArray *)getAllRecord;


@end

NS_ASSUME_NONNULL_END
