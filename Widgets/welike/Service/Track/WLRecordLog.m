//
//  WLRecordLog.m
//  welike
//
//  Created by gyb on 2018/12/4.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRecordLog.h"


@implementation WLRecordLog

+(void)writeNo:(NSString *)typeStr text:(NSString *)text
{
   #ifndef __WELIKE_TEST_
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *fileDirectory = [tmpDir stringByAppendingPathComponent:@"RequestTimeLog"];

    //用于写入的data
    NSMutableData *writerData = [[NSMutableData alloc] init];
    //用于记录旧的data
    NSData *readeData;
    
    NSInteger lineNum = 0;
    
    //检查文件是否存在
    if([[NSFileManager defaultManager] fileExistsAtPath:fileDirectory])
    {
        readeData = [NSData dataWithContentsOfFile:fileDirectory];
        [writerData appendData:readeData];
        
        NSString *readStr = [NSString stringWithContentsOfFile:fileDirectory encoding:NSUTF8StringEncoding error:nil];
        
        if (readStr.length > 0)
        {
            NSArray *readLines = [readStr componentsSeparatedByString:@"\n"];
            lineNum = readLines.count - 1; //去掉一个空格的情况
        }
    }

    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss-SSSS"];
    NSString *detailLocationString =[dateformatter stringFromDate:[NSDate date]];

    
    NSString *requestInfoStr = [NSString stringWithFormat:@"%@==%ld===time:%@==ctime:%@\n",typeStr,lineNum + 1,detailLocationString,text];
    [writerData appendData:[requestInfoStr dataUsingEncoding:NSUTF8StringEncoding]];
    [writerData writeToFile:fileDirectory atomically:YES];
   
    #endif
}

+(void)writeNo1:(NSString *)typeStr text:(NSString *)text
{
#ifdef __WELIKE_TEST_
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *fileDirectory = [tmpDir stringByAppendingPathComponent:@"RequestTimeLog1"];
    
    //用于写入的data
    NSMutableData *writerData = [[NSMutableData alloc] init];
    //用于记录旧的data
    NSData *readeData;
    
    NSInteger lineNum = 0;
    
    //检查文件是否存在
    if([[NSFileManager defaultManager] fileExistsAtPath:fileDirectory])
    {
        readeData = [NSData dataWithContentsOfFile:fileDirectory];
        [writerData appendData:readeData];
        
        NSString *readStr = [NSString stringWithContentsOfFile:fileDirectory encoding:NSUTF8StringEncoding error:nil];
        
        if (readStr.length > 0)
        {
            NSArray *readLines = [readStr componentsSeparatedByString:@"\n"];
            lineNum = readLines.count - 1; //去掉一个空格的情况
        }
    }
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss-SSSS"];
    NSString *detailLocationString =[dateformatter stringFromDate:[NSDate date]];
    
    
    NSString *requestInfoStr = [NSString stringWithFormat:@"%@==%ld===time:%@==ctime:%@\n",typeStr,lineNum + 1,detailLocationString,text];
    [writerData appendData:[requestInfoStr dataUsingEncoding:NSUTF8StringEncoding]];
    [writerData writeToFile:fileDirectory atomically:YES];
#endif
}


@end
