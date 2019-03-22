//
//  LuuUtils.m
//  Luuphone
//
//  Created by liubin on 15/5/12.
//  Copyright (c) 2015年 luuphone. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#include <zlib.h>
#import <sys/utsname.h>
#import "LuuUtils.h"
#import "NSString+LuuBase.h"

#define kApplicationUUIDKey @"ApplicationUUID"

NSString * const kThumbnailStrategyFixed    = @"fixed";
NSString * const kThumbnailStrategyLFit     = @"lfit";
NSString * const kThumbnailStrategyMFit     = @"mfit";

NSString * const kCommonCryptoErrorDomain = @"CommonCryptoErrorDomain";

@implementation NSError (CommonCryptoErrorDomain)

+ (NSError *)errorWithCCCryptorStatus:(CCCryptorStatus)status
{
    NSError *result = [NSError errorWithDomain:kCommonCryptoErrorDomain code:status userInfo:nil];
    return result;
}

@end

static void FixKeyLengths(CCAlgorithm algorithm, NSMutableData *keyData, NSMutableData *ivData)
{
    NSUInteger keyLength = [keyData length];
    switch (algorithm)
    {
        case kCCAlgorithmAES128:
        {
            if (keyLength < 16)
            {
                [keyData setLength:16];
            }
            else if (keyLength < 24)
            {
                [keyData setLength:24];
            }
            else
            {
                [keyData setLength:32];
            }
            break;
        }
        case kCCAlgorithmDES:
        {
            [keyData setLength:8];
            break;
        }
        case kCCAlgorithm3DES:
        {
            [keyData setLength:24];
            break;
        }
        case kCCAlgorithmCAST:
        {
            if (keyLength < 5)
            {
                [keyData setLength:5];
            }
            else if (keyLength > 16)
            {
                [keyData setLength:16];
            }
            break;
        }
        case kCCAlgorithmRC4:
        {
            if (keyLength > 512)
            {
                [keyData setLength:512];
            }
            break;
        }
        default:
            break;
    }
    
    [ivData setLength:[keyData length]];
}

@interface LuuUtils ()

+ (NSData *)runCryptor:(CCCryptorRef)cryptor data:(NSData *)data result:(CCCryptorStatus *)status;

@end

@implementation LuuUtils

#pragma mark common methods
+ (NSString *)uuid
{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSString *)deviceId
{
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationUUIDKey];
    if (deviceId == nil || [deviceId length] == 0)
    {
        deviceId = [LuuUtils uuid];
        [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:kApplicationUUIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return deviceId;
}

+ (CGFloat)mainScreenScale
{
    return [UIScreen mainScreen].scale;
}

+ (CGSize)mainScreenBounds
{
    return [UIScreen mainScreen].bounds.size;
}

+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSInteger)appVersionCode
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] integerValue];
}

+ (NSString *)appDisplayName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)preferredLanguage
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    return [languages objectAtIndex:0];
}

+ (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

#pragma mark file system methods
+ (void)createDirectory:(NSString *)path
{
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (void)removeFilesInPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    if (filesArray)
    {
        for (NSString* fileName in filesArray)
        {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
}

+ (void)removeFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (void)p_removeFile:(NSString *)filePath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]){
        BOOL result = [fileManager removeItemAtPath:filePath error:nil];
        if (result)
        {
            NSLog(@"移除文件成功1");
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

+ (size_t)archiver:(id<NSCoding>)obj withKey:(NSString *)key toPath:(NSString *)path
{
    NSString *directory = [path stringByDeletingLastPathComponent];
    [LuuUtils removeFile:path];
    [LuuUtils createDirectory:directory];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    @try {
        [archiver encodeObject:obj forKey:key];
        [archiver finishEncoding];
    }
    @catch (NSException *exception) {
        return 0;
    }
    
    if (![data writeToFile:path atomically:YES])
    {
        return 0;
    }
    
    return [data length];
}

+ (id)unarchiverWithKey:(NSString *)key fromPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    id obj = nil;
    
    @try {
        obj = [unarchiver decodeObjectForKey:key];
        [unarchiver finishDecoding];
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    return obj;
}

#pragma mark encryption and decryption methods
+ (NSString *)md5Encode:(NSString *)source
{
    if ([source length] > 0)
    {
        NSString *sourceCopy = [source copy];
        const char *cStr = [sourceCopy UTF8String];
        unsigned char result[16];
        CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
        return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    }
    
    return @"";
}

+ (NSData *)SHA1Hash:(NSData *)source
{
    if ([source length] <= 0) return nil;
    
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    (void)CC_SHA1([source bytes], (CC_LONG)[source length], hash);
    return ([NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH]);
}

+ (NSData *)SHA224Hash:(NSData *)source
{
    if ([source length] <= 0) return nil;
    
    unsigned char hash[CC_SHA224_DIGEST_LENGTH];
    (void)CC_SHA224([source bytes], (CC_LONG)[source length], hash);
    return ([NSData dataWithBytes:hash length:CC_SHA224_DIGEST_LENGTH]);
}

+ (NSData *)SHA256Hash:(NSData *)source
{
    if ([source length] <= 0) return nil;
    
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    (void)CC_SHA256([source bytes], (CC_LONG)[source length], hash);
    return ([NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH]);
}

+ (NSData *)SHA384Hash:(NSData *)source
{
    if ([source length] <= 0) return nil;
    
    unsigned char hash[CC_SHA384_DIGEST_LENGTH];
    (void)CC_SHA384([source bytes], (CC_LONG)[source length], hash);
    return ([NSData dataWithBytes:hash length:CC_SHA384_DIGEST_LENGTH]);
}

+ (NSData *)SHA512Hash:(NSData *)source
{
    if ([source length] <= 0) return nil;
    
    unsigned char hash[CC_SHA512_DIGEST_LENGTH];
    (void)CC_SHA512([source bytes], (CC_LONG)[source length], hash);
    return ([NSData dataWithBytes:hash length:CC_SHA512_DIGEST_LENGTH]);
}

+ (NSData *)AES256EncryptedData:(NSData *)source usingKey:(id)key error:(NSError **)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self dataEncrypted:source
                          usingAlgorithm:kCCAlgorithmAES128
                                     key:key
                                 options:kCCOptionPKCS7Padding
                                   error:&status];
    
    if (result != nil) return result;
    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }
    
    return nil;
}

+ (NSData *)decryptedAES256Data:(NSData *)source usingKey:(id)key error:(NSError **)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self decryptedData:source
                          usingAlgorithm:kCCAlgorithmAES128
                                     key:key
                                 options:kCCOptionPKCS7Padding
                                   error:&status];
    
    if (result != nil) return result;
    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus: status];
    }
    
    return nil;
}

+ (NSData *)DESEncryptedData:(NSData *)source usingKey:(id)key error:(NSError **)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self dataEncrypted:source
                          usingAlgorithm:kCCAlgorithmDES
                                     key:key
                                 options:kCCOptionPKCS7Padding
                                   error:&status];
    
    if (result != nil) return result;
    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus: status];
    }
    
    return ( nil );
}

+ (NSData *)decryptedDESData:(NSData *)source usingKey:(id)key error:(NSError **)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self decryptedData:source
                          usingAlgorithm:kCCAlgorithmDES
                                     key:key
                                 options:kCCOptionPKCS7Padding
                                   error:&status];
    
    if (result != nil) return result;
    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus: status];
    }
    
    return nil;
}

+ (NSData *)CASTEncryptedData:(NSData *)source usingKey:(id)key error:(NSError **)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self dataEncrypted:source
                          usingAlgorithm:kCCAlgorithmCAST
                                     key:key
                                 options:kCCOptionPKCS7Padding
                                   error:&status];
    
    if (result != nil) return result;
    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus: status];
    }
    
    return nil;
}

+ (NSData *)decryptedCASTData:(NSData *)source usingKey:(id)key error:(NSError **)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self decryptedData:source
                          usingAlgorithm:kCCAlgorithmCAST
                                     key:key
                                 options:kCCOptionPKCS7Padding
                                   error:&status];
    
    if (result != nil) return result;
    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus: status];
    }
    
    return nil;
}

+ (NSData *)runCryptor:(CCCryptorRef)cryptor data:(NSData *)data result:(CCCryptorStatus *)status
{
    if ([data length] <= 0) return nil;
    
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[data length], true);
    void * buf = malloc(bufsize);
    size_t bufused = 0;
    size_t bytesTotal = 0;
    *status = CCCryptorUpdate(cryptor, [data bytes], (size_t)[data length], buf, bufsize, &bufused);
    if (*status != kCCSuccess)
    {
        free(buf);
        return nil;
    }
    
    bytesTotal += bufused;
    
    *status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
    if (*status != kCCSuccess)
    {
        free(buf);
        return nil;
    }
    
    bytesTotal += bufused;
    
    return ([NSData dataWithBytesNoCopy:buf length:bytesTotal]);
}

+ (NSData *)dataEncrypted:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                    error:(CCCryptorStatus *)error
{
    return ([self dataEncrypted:source
                 usingAlgorithm:algorithm
                            key:key
           initializationVector:nil
                        options:0
                          error:error]);
}

+ (NSData *)dataEncrypted:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error
{
    return ([self dataEncrypted:source
                 usingAlgorithm:algorithm
                            key:key
           initializationVector:nil
                        options:options
                          error:error]);
}

+ (NSData *)dataEncrypted:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
     initializationVector:(id)iv
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    NSParameterAssert([key isKindOfClass:[NSData class]] || [key isKindOfClass:[NSString class]]);
    NSParameterAssert(iv == nil || [iv isKindOfClass:[NSData class]] || [iv isKindOfClass:[NSString class]]);
    
    NSMutableData *keyData = nil;
    NSMutableData *ivData = nil;
    
    if ([key isKindOfClass:[NSData class]])
    {
        keyData = (NSMutableData *)[key mutableCopy];
    }
    else
    {
        keyData = [[key dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    
    if ([iv isKindOfClass:[NSString class]])
    {
        ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    }
    else
    {
        ivData = (NSMutableData *)[iv mutableCopy];
    }
    
    FixKeyLengths(algorithm, keyData, ivData);
    
    status = CCCryptorCreate(kCCEncrypt, algorithm, options,
                             [keyData bytes], [keyData length], [ivData bytes],
                             &cryptor);
    if (status != kCCSuccess)
    {
        if (error != NULL)
        {
            *error = status;
        }
        return nil;
    }
    
    NSData * result = [LuuUtils runCryptor:cryptor data:source result:&status];
    if ((result == nil) && (error != NULL))
    {
        *error = status;
    }
    
    CCCryptorRelease(cryptor);
    return result;
}

+ (NSData *)decryptedData:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                    error:(CCCryptorStatus *)error
{
    return ([self decryptedData:source
                 usingAlgorithm:algorithm
                            key:key
           initializationVector:nil
                        options:0
                          error:error]);
}

+ (NSData *)decryptedData:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error
{
    return ([self decryptedData:source
                 usingAlgorithm:algorithm
                            key:key
           initializationVector:nil
                        options:options
                          error:error]);
}

+ (NSData *)decryptedData:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
     initializationVector:(id)iv
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error
{
    if ([source length] <= 0) return nil;
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    NSParameterAssert([key isKindOfClass:[NSData class]] || [key isKindOfClass:[NSString class]]);
    NSParameterAssert(iv == nil || [iv isKindOfClass:[NSData class]] || [iv isKindOfClass:[NSString class]]);
    
    NSMutableData *keyData = nil;
    NSMutableData *ivData = nil;
    
    if ([key isKindOfClass:[NSData class]])
    {
        keyData = (NSMutableData *)[key mutableCopy];
    }
    else
    {
        keyData = [[key dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    
    if ([iv isKindOfClass:[NSString class]])
    {
        ivData = [[iv dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    else
    {
        ivData = (NSMutableData *)[iv mutableCopy];
    }
    
    FixKeyLengths(algorithm, keyData, ivData);
    
    status = CCCryptorCreate(kCCDecrypt, algorithm, options,
                             [keyData bytes], [keyData length], [ivData bytes],
                             &cryptor);
    if (status != kCCSuccess)
    {
        if (error != NULL)
        {
            *error = status;
        }
        return nil;
    }
    
    NSData *result = [LuuUtils runCryptor:cryptor data:source result:&status];
    if ((result == nil) && (error != NULL))
    {
        *error = status;
    }
    
    CCCryptorRelease(cryptor);
    return result;
}

+ (NSData *)HMAC:(NSData *)source withAlgorithm:(CCHmacAlgorithm)algorithm
{
    if ([source length] <= 0) return nil;
    
    return ([LuuUtils HMAC:source withAlgorithm:algorithm key:nil]);
}

+ (NSData *)HMAC:(NSData *)source withAlgorithm:(CCHmacAlgorithm)algorithm key:(id)key
{
    if ([source length] <= 0) return nil;
    
    NSParameterAssert(key == nil || [key isKindOfClass:[NSData class]] || [key isKindOfClass:[NSString class]]);
    
    NSData * keyData = nil;
    if ([key isKindOfClass:[NSString class]])
    {
        keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        keyData = (NSData *)key;
    }
    
    unsigned char buf[CC_SHA1_DIGEST_LENGTH];
    CCHmac(algorithm, [keyData bytes], [keyData length], [source bytes], [source length], buf);
    
    return ([NSData dataWithBytes:buf length:(algorithm == kCCHmacAlgMD5 ? CC_MD5_DIGEST_LENGTH : CC_SHA1_DIGEST_LENGTH)]);
}

#pragma mark zip methods
+ (NSData *)gzipInflate:(NSData *)data
{
    if ([data length] == 0) return nil;
    
    unsigned full_length = (unsigned)[data length];
    unsigned half_length = (unsigned)([data length] / 2);
    
    NSMutableData *decompressed = [NSMutableData dataWithLength:full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef*)[data bytes];
    strm.avail_in = (uInt)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit(&strm) != Z_OK) return nil;
    
    while (!done)
    {
        if (strm.total_out >= [decompressed length])
        {
            [decompressed increaseLengthBy:half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
        {
            done = YES;
        }
        else if (status != Z_OK)
        {
            break;
        }
    }
    if (inflateEnd(&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength:strm.total_out];
        return [NSData dataWithData:decompressed];
    }
    
    return nil;
}

+ (NSData *)gzipInflate2:(NSData *)data
{
    if ([data length] <= 0) return nil;
    
    unsigned full_length = (unsigned)[data length];
    unsigned half_length = (unsigned)([data length] / 2);
    
    NSMutableData *decompressed = [NSMutableData dataWithLength:(full_length + half_length)];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
        {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
        {
            done = YES;
        }
        else if (status != Z_OK)
        {
            break;
        }
    }
    if (inflateEnd(&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength:strm.total_out];
        return [NSData dataWithData:decompressed];
    }
    
    return nil;
}

+ (NSData *)gzipDeflate:(NSData *)data
{
    if ([data length] <= 0) return nil;
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef*)[data bytes];
    strm.avail_in = (uInt)[data length];
    
    if (deflateInit(&strm, Z_DEFAULT_COMPRESSION) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];
    
    do {
        if (strm.total_out >= [compressed length])
        {
            [compressed increaseLengthBy:16384];
        }
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([compressed length] - strm.total_out);
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

+ (NSData *)gzipDeflate2:(NSData *)data
{
    if ([data length] <= 0) return nil;
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15 + 16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        if (strm.total_out >= [compressed length])
        {
            [compressed increaseLengthBy:16384];
        }
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([compressed length] - strm.total_out);
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

+ (NSString *)getThumbnailPicUrl:(NSString *)originalPicUrl strategy:(NSString *)strategy width:(CGFloat)width height:(CGFloat)height {
    //阿里云宽高尺寸不能超过4096
    if (height > 4096)
    {
        width = (4096 *width)/height;
        height = 4096;
    }
    
    if (width > 4096)
    {
        height = (4096*height)/width;
        width = 4096;
    }
    
    return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_%@,h_%ld,w_%ld",
            originalPicUrl,
            strategy,
            (long)height,
            (long)width];
}

@end
