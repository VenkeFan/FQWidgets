//
//  WLUploadRecord.m
//  welike
//
//  Created by gyb on 2019/1/30.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLUploadRecord.h"

@implementation WLUploadRecord

//添加一个记录
+(void)addImageWithIdentifer:(NSString *)idertifer width:(CGFloat)width height:(CGFloat)height imageUrl:(NSString *)urlString
{
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:WLFileDBName];
    NSString *tableName = WLUploadFileTable;
  
    [store createTableWithName:tableName];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:urlString,@"fileUrl",
                         [NSString stringWithFormat:@"%f",width],@"width",
                         [NSString stringWithFormat:@"%f",height],@"height",nil];
    
    NSString *jsonStr = [NSDictionary dicToJsonStr:dic];
    
    [store putString:jsonStr withId:idertifer intoTable:tableName];
}

//删除一个记录
+(void)removeImageWithidertifer:(NSString *)idertifer
{
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:WLFileDBName];
    NSString *tableName = WLUploadFileTable;
   
    [store createTableWithName:tableName];
    
    [store deleteObjectById:idertifer fromTable:tableName];
}

//查询一个已经上传成功了的图片url的记录
+(NSString *)getUploadImageUrlWithidertifer:(NSString *)idertifer
{
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:WLFileDBName];
    NSString *tableName = WLUploadFileTable;
 
    [store createTableWithName:tableName];
    
    return  [store getStringById:idertifer fromTable:tableName];
}


//仅用于测试
+(NSArray *)getAllRecord
{
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:WLFileDBName];
    NSString *tableName = WLUploadFileTable;

    [store createTableWithName:tableName];
    
    return [store getAllItemsFromTable:tableName];
}

@end
