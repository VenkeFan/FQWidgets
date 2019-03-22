//
//  WLAlbumPicModel.m
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLAlbumPicModel.h"
#import <objc/runtime.h>

@implementation WLAlbumPicModel

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    if (!json) {
        return nil;
    }
    
    WLAlbumPicModel *model = [[WLAlbumPicModel alloc] init];
    model.ID = [json stringForKey:@"id"];
    model.type = [json stringForKey:@"type"];
    model.source = [[json stringForKey:@"source"] convertToHttps];
    model.originalImageUrl = [[json stringForKey:@"original_image_url"] convertToHttps];
    model.waterMarkUrl = [[json stringForKey:@"watermark_url"] convertToHttps];
    model.width = [json integerForKey:@"image-width" def:0];
    model.height = [json integerForKey:@"image-height" def:0];
    model.created = [json longLongForKey:@"created" def:0];
    model.picUrl = model.source;
    model.createdMonth = [model monthTimeString];
    
    NSDictionary *contentDic = [json objectForKey:@"content"];
    model.postID = [contentDic stringForKey:@"id"];
    model.postContent = [contentDic stringForKey:@"content"];
    model.userName = [[contentDic objectForKey:@"user"] stringForKey:@"nickName"];
    
    [model calculatePicThumbnailInfoWithWidth:kScreenWidth * 0.5];
    
    return model;
}

- (NSString *)monthTimeString {
    NSString *result = nil;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    [dateFormatter setDateFormat:@"MM-yyyy"];
    result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.created / 1000]];
    
    return  result;
}

@end
