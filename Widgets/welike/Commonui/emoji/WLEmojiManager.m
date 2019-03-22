//
//  EmojiManager.m
//  GBRichLabel
//
//  Created by gyb on 2018/4/16.
//  Copyright © 2018年 gyb. All rights reserved.
//

#import "WLEmojiManager.h"

static NSArray* emotionsArray = nil;


@implementation WLEmojiManager


+(NSArray *)emotionsArray
{
    if (!emotionsArray)
    {
        //到plist里面遍历表情,添加到数组
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
        NSArray *array = [[NSArray alloc]initWithContentsOfFile:plistPath];
        NSMutableArray *emoticons = [NSMutableArray arrayWithCapacity:array.count];
        //WBEmotionsModel  *emotionsModel;
        for (NSDictionary *dic in array)
        {
            [emoticons addObject:[dic objectForKey:@"name"]];
        }
        emotionsArray = emoticons;
    }
    return emotionsArray;
}


//+(void)aaaa
//{
//    NSString *textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
//                                                                     pathForResource:@"data3" ofType:@"txt"] encoding:NSUTF8StringEncoding error: nil];
//
//    NSArray *array = [textFileContents componentsSeparatedByString:@"\n"];
//
//    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:0];
//
//    for (int i = 0; i<array.count-1; i++)
//    {
//        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:array[i],@"name", nil];
//        [all addObject:dict];
//    }
//
//
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
//    NSString *filePatch = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"emoji.plist"];
//
//
//
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL success = [fileManager copyItemAtPath:plistPath toPath:filePatch error:nil];
//
//    BOOL aa =  [all writeToFile:filePatch atomically:NO];
//
//      NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:filePatch];
//
//
//    NSLog(@"%@",data);
//
//
//
//    NSLog(@"===================");
//
//
// //   NSError *error = nil;
//
////    NSData *result = [textFileContents dataUsingEncoding:NSUTF8StringEncoding];
////    NSDictionary *items = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
//
//}

@end
