//
//  WLMagicEffectCacheManager.m
//  welike
//
//  Created by fan qi on 2018/11/30.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicEffectCacheManager.h"
#import "SSZipArchive.h"

#define kZipSuffix          @"zip"

static NSString * const kEffectFilterPath = @"filters";
static NSString * const kEffectPasterPath = @"pasters";

@interface WLMagicEffectCacheManager ()

@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, copy) NSString *filterPath;
@property (nonatomic, copy) NSString *pasterPath;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation WLMagicEffectCacheManager

+ (instancetype)instance {
    static WLMagicEffectCacheManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[WLMagicEffectCacheManager alloc] init];
    });
    return _manager;
}

- (BOOL)isExist:(NSString *)key effectType:(WLMagicBasicModelType)effectType dstPath:(NSString *__autoreleasing *)dstPath {
    if (key.length == 0) {
        return NO;
    }
    
    NSString *filePath = [self filePathWithKey:key effectType:effectType directoryPath:nil];
    if (filePath.length == 0) {
        return NO;
    }
    
    key = [self removePathSuffix:key];
    filePath = [self removePathSuffix:filePath];
    filePath = [filePath stringByAppendingPathComponent:key.pathComponents.lastObject];
    
    BOOL exist = [self.fileManager fileExistsAtPath:filePath isDirectory:nil];
    if (exist && dstPath) {
        *dstPath = filePath;
    }
    return exist;
}

- (void)moveFileAtPath:(NSString *)srcPath
      toPathComponent:(NSString *)dstPathComponent
            effectType:(WLMagicBasicModelType)effectType
             completed:(void(^)(NSString *))completed {
    NSString *directoryPath = nil;
    NSString *filePath = [self filePathWithKey:dstPathComponent effectType:effectType directoryPath:&directoryPath];
    if (directoryPath.length == 0 || filePath.length == 0) {
        return;
    }
    
    if (![self.fileManager fileExistsAtPath:directoryPath isDirectory:nil]) {
        [self.fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self.fileManager removeItemAtPath:filePath error:nil];
    NSError *error = nil;
    [self.fileManager moveItemAtPath:srcPath toPath:filePath error:&error];
    if (error) {
        return;
    }
    
    if ([filePath hasSuffix:kZipSuffix]) {
        NSString *unzipDirectoryPath = [self removePathSuffix:filePath];
        BOOL succeed = [SSZipArchive unzipFileAtPath:filePath toDestination:unzipDirectoryPath];
        
        if (succeed) {
            [self.fileManager removeItemAtPath:filePath error:nil];
            
            dstPathComponent = [self removePathSuffix:dstPathComponent];
            NSString *finalPath = [unzipDirectoryPath stringByAppendingPathComponent:dstPathComponent.pathComponents.lastObject];
            if (completed) {
                completed(finalPath);
            }
        }
    }
}

- (NSString *)filePathWithKey:(NSString *)key effectType:(WLMagicBasicModelType)effectType directoryPath:(NSString **)directoryPath {
    NSString *filePath = nil;
    
    switch (effectType) {
        case WLMagicBasicModelType_Filter: {
            filePath = [self.filterPath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
            if (directoryPath) {
                *directoryPath = self.filterPath;
            }
        }
            break;
        case WLMagicBasicModelType_Paster: {
            filePath = [self.pasterPath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
            if (directoryPath) {
                *directoryPath = self.pasterPath;
            }
        }
            break;
        case WLMagicBasicModelType_Unknown:
            break;
    }
    
    return filePath;
}

- (NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
    return filename;
}

- (NSString *)removePathSuffix:(NSString *)path {
    if ([path hasSuffix:kZipSuffix]) {
        return [path stringByDeletingPathExtension];
    }
    return path;
}

#pragma mark - Getter

- (NSString *)rootPath {
    if (!_rootPath) {
        _rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    }
    return _rootPath;
}

- (NSString *)filterPath {
    if (!_filterPath) {
        _filterPath = [self.rootPath stringByAppendingPathComponent:kEffectFilterPath];
    }
    return _filterPath;
}

- (NSString *)pasterPath {
    if (!_pasterPath) {
        _pasterPath = [self.rootPath stringByAppendingPathComponent:kEffectPasterPath];
    }
    return _pasterPath;
}

- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

@end
