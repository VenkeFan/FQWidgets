//
//  WLMagicEffectViewModel.m
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicEffectViewModel.h"
#import "WLMagicFilterModel.h"
#import "WLMagicPasterModel.h"
#import "WLMagicEffectCacheManager.h"
#import "WLMagicEffectDownloadManager.h"

static NSString * const kEffectFilterAPI = @"https://img.welike.in/video_filters.json";
static NSString * const kEffectPasterAPI = @"https://img.welike.in/video_stickers.json";

@implementation WLMagicEffectViewModel

- (void)fetchEffectFilterArray:(void (^)(NSArray<WLMagicFilterModel *> *, NSError *))completed {
    void(^completionHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(nil, error);
                }
            });
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSArray *filterJsons = result[@"filters"];
                NSMutableArray<WLMagicFilterModel *> *filterArray = [NSMutableArray arrayWithCapacity:filterJsons.count];
                
                for (NSInteger i = 0; i < filterJsons.count; i++) {
                    WLMagicFilterModel *filterModel = [WLMagicFilterModel parseWithNetworkJson:filterJsons[i]];
                    NSString *filePath = nil;
                    [[WLMagicEffectCacheManager instance] isExist:filterModel.resourceUrl effectType:WLMagicBasicModelType_Filter dstPath:&filePath];
                    filterModel.localPath = filePath;
                    
                    if (filterModel && filterModel.isOnline) {
                        [filterArray addObject:filterModel];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed) {
                        completed(filterArray, nil);
                    }
                });
            }
        }
    };
    
    NSURL *url = [NSURL URLWithString:kEffectFilterAPI];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithURL:url
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                      completionHandler(data, error);
                                  }];
    [task resume];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableArray<WLMagicFilterModel *> *dataArray = [NSMutableArray array];
//
//        WLMagicFilterModel *emptyModel = [WLMagicFilterModel defaultModel];
//        [dataArray addObject:emptyModel];
//
//        NSString *directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"FilterResource.bundle"]];
//
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSArray *subPaths = [fileManager contentsOfDirectoryAtPath:directory error:nil];
//
//        for (int i = 0; i < subPaths.count; i++ ){
//            NSString *path = [directory stringByAppendingPathComponent:subPaths[i]];
//            AliyunEffectFilter *effectFilter = [[AliyunEffectFilter alloc] initWithFile:path];
//
//            WLMagicFilterModel *filterModel = [WLMagicFilterModel modelWithEffect:effectFilter];
//            [dataArray addObject:filterModel];
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (completed) {
//                completed(dataArray);
//            }
//        });
//    });
}

- (void)fetchEffectPasterArray:(void (^)(NSArray<WLMagicPasterModel *> *, NSError *))completed {
    void(^completionHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(nil, error);
                }
            });
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSArray *pasterJsons = result[@"stickers"];
                NSMutableArray<WLMagicPasterModel *> *pasterArray = [NSMutableArray arrayWithCapacity:pasterJsons.count];
                
                for (NSInteger i = 0; i < pasterJsons.count; i++) {
                    WLMagicPasterModel *pasterModel = [WLMagicPasterModel parseWithNetworkJson:pasterJsons[i]];
                    NSString *filePath = nil;
                    [[WLMagicEffectCacheManager instance] isExist:pasterModel.resourceUrl effectType:WLMagicBasicModelType_Paster dstPath:&filePath];
                    pasterModel.localPath = filePath;
                    
                    if (pasterModel && pasterModel.isOnline) {
                        [pasterArray addObject:pasterModel];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed) {
                        completed(pasterArray, error);
                    }
                });
            }
        }
    };
    
    NSURL *url = [NSURL URLWithString:kEffectPasterAPI];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithURL:url
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                      completionHandler(data, error);
                                  }];
    [task resume];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableArray<WLMagicPasterModel *> *dataArray = [NSMutableArray array];
//
//        WLMagicPasterModel *emptyModel = [WLMagicPasterModel defaultModel];
//        [dataArray addObject:emptyModel];
//
//        NSString *directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"PasterResource.bundle"]];
//
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSArray *subPaths = [fileManager contentsOfDirectoryAtPath:directory error:nil];
//
//        for (int i = 0; i < subPaths.count; i++) {
//            NSString *path = [directory stringByAppendingPathComponent:subPaths[i]];
//            AliyunEffectPaster *effectPaster = [[AliyunEffectPaster alloc] initWithFile:path];
//
//            WLMagicPasterModel *pasterModel = [WLMagicPasterModel modelWithEffect:effectPaster];
//            [dataArray addObject:pasterModel];
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (completed) {
//                completed(dataArray);
//            }
//        });
//    });
}

@end
