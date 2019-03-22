//
//  LuuLogger.m
//  Luuphone
//
//  Created by liubin on 13-3-25.
//  Copyright (c) 2013年 Luuphone. All rights reserved.
//

#import "LuuLogger.h"

#define kDefaultName @"log"

static LuuLogger *_gLogger = nil;

@interface LuuLogger ()

@property (nonatomic, strong) NSMutableArray *tags;

- (void)writeToFile:(NSString *)log;

@end

@implementation LuuLogger

@synthesize enable = _enable;
@synthesize fileMode = _fileMode;
@synthesize fileName = _fileName;
@synthesize tags = _tags;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.enable = NO;
        self.fileMode = NO;

        self.tags = [[NSMutableArray alloc] initWithCapacity:5];
        
        // 根据当前时间生成log文件名
        long time = [[NSDate date] timeIntervalSince1970] * 1000.0f;
        NSString *logName = [NSString stringWithFormat:@"%@_%ld.log", kDefaultName, time];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentDirectory = [paths objectAtIndex:0];
        [fileManager changeCurrentDirectoryPath:[documentDirectory stringByExpandingTildeInPath]];
        self.fileName = [documentDirectory stringByAppendingPathComponent:logName];
    }
    
    return self;
}

#pragma mark methods
- (void)appendTag:(NSString *)tag
{
    for (NSString *t in self.tags)
    {
        if ([t isEqualToString:tag] == YES) return;
    }
    [self.tags addObject:tag];
}

- (void)log:(NSString *)log tag:(NSString *)tag
{
    if (!log) return;
    if (self.enable == YES)
    {
        if ([tag length] > 0)
        {
            for (NSString *tagc in self.tags)
            {
                if ([tagc isEqualToString:tag] == YES)
                {
                    NSLog(@"%@", log);
                    if (self.fileMode == YES)
                    {
                        [self writeToFile:log];
                    }
                    break;
                }
            }
        }
        else
        {
            NSLog(@"%@", log);
            if (self.fileMode == YES)
            {
                [self writeToFile:log];
            }
        }
    }
}

#pragma mark private methods
- (void)writeToFile:(NSString *)log
{
    // 获取当前系统时间
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss-SSSS"];
    NSString *detailLocationString=[dateformatter stringFromDate:[NSDate date]];
    
    // 写文件
    @synchronized(self)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:self.fileName])
        {
            [fileManager createFileAtPath:self.fileName contents:nil attributes:nil];
        }
        
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:self.fileName];
        [fileHandler seekToEndOfFile];
        NSString *temp = [NSString stringWithFormat:@"\r\n---------- \r\n%@ ---------- %@", detailLocationString, log];
        [fileHandler writeData:[temp dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

#pragma mark WCHLogger singleton methods
+ (LuuLogger *)share
{
    if (!_gLogger)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gLogger = [[LuuLogger alloc] init];
        });
    }
    
    return _gLogger;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
    {
		if (!_gLogger)
        {
			_gLogger = [super allocWithZone:zone];
			return _gLogger;
		}
	}
    
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return _gLogger;
}

@end
