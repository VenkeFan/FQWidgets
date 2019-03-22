//
//  LuuUtils.h
//  Luuphone
//
//  Created by liubin on 15/5/12.
//  Copyright (c) 2015年 luuphone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDBaseViewController.h"
#import <Foundation/NSError.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

extern NSString * const kThumbnailStrategyFixed;
extern NSString * const kThumbnailStrategyLFit;
extern NSString * const kThumbnailStrategyMFit;

@interface NSError (CommonCryptoErrorDomain)

+ (NSError *)errorWithCCCryptorStatus:(CCCryptorStatus)status;

@end

@interface LuuUtils : NSObject

// 通用方法
+ (NSString *)uuid;
+ (NSString *)deviceId;
+ (CGFloat)mainScreenScale;
+ (CGSize)mainScreenBounds;
+ (NSString *)appVersion;
+ (NSInteger)appVersionCode;
+ (NSString *)appDisplayName;
+ (NSString *)preferredLanguage;
+ (NSString *)deviceModel;

// 文件系统方法(非线程安全)
+ (void)createDirectory:(NSString *)path;
+ (void)removeFilesInPath:(NSString *)path;
+ (void)removeFile:(NSString *)path;
+ (size_t)archiver:(id<NSCoding>)obj withKey:(NSString *)key toPath:(NSString *)path;
+ (id)unarchiverWithKey:(NSString *)key fromPath:(NSString *)path;

// 加解密
+ (NSString *)md5Encode:(NSString *)source;
+ (NSData *)SHA1Hash:(NSData *)source;
+ (NSData *)SHA224Hash:(NSData *)source;
+ (NSData *)SHA256Hash:(NSData *)source;
+ (NSData *)SHA384Hash:(NSData *)source;
+ (NSData *)SHA512Hash:(NSData *)source;

+ (NSData *)AES256EncryptedData:(NSData *)source usingKey:(id)key error:(NSError **)error;
+ (NSData *)decryptedAES256Data:(NSData *)source usingKey:(id)key error:(NSError **)error;
+ (NSData *)DESEncryptedData:(NSData *)source usingKey:(id)key error:(NSError **)error;
+ (NSData *)decryptedDESData:(NSData *)source usingKey:(id)key error:(NSError **)error;
+ (NSData *)CASTEncryptedData:(NSData *)source usingKey:(id)key error:(NSError **)error;
+ (NSData *)decryptedCASTData:(NSData *)source usingKey:(id)key error:(NSError **)error;

+ (NSData *)dataEncrypted:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                    error:(CCCryptorStatus *)error;
+ (NSData *)dataEncrypted:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error;
+ (NSData *)dataEncrypted:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
     initializationVector:(id)iv
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error;
+ (NSData *)decryptedData:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                    error:(CCCryptorStatus *)error;
+ (NSData *)decryptedData:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error;
+ (NSData *)decryptedData:(NSData *)source
           usingAlgorithm:(CCAlgorithm)algorithm
                      key:(id)key
     initializationVector:(id)iv
                  options:(CCOptions)options
                    error:(CCCryptorStatus *)error;

+ (NSData *)HMAC:(NSData *)source withAlgorithm:(CCHmacAlgorithm)algorithm;
+ (NSData *)HMAC:(NSData *)source withAlgorithm:(CCHmacAlgorithm)algorithm key:(id)key;

// zip相关方法
+ (NSData *)gzipInflate:(NSData *)data;
+ (NSData *)gzipDeflate:(NSData *)data;
+ (NSData *)gzipInflate2:(NSData *)data;
+ (NSData *)gzipDeflate2:(NSData *)data;

//
+ (NSString *)getThumbnailPicUrl:(NSString *)originalPicUrl strategy:(NSString *)strategy width:(CGFloat)width height:(CGFloat)height;

@end
