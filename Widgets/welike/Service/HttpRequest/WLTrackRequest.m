//
//  WLTrackRequest.m
//  welike
//
//  Created by 刘斌 on 2018/6/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackRequest.h"
#import "WLAccountManager.h"
#import "LFCGzipUtility.h"
#import "WLRecordLog.h"

@implementation WLTrackRequest

- (id)initTrackRequest
{
    return [super initWithType:AFHttpOperationTypeNormal hostName:[AppContext getTrackHostName] api:@"collection/app" method:AFHttpOperationMethodPOST];
}

- (void)sendTracks:(NSArray *)tracks successed:(trackSuccessed)successed error:(failedBlock)error
{
    if ([tracks count] == 0)
    {
        if (successed)
        {
            successed();
        }
        return;
    }
    
    NSMutableArray *dotDatas = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableDictionary *publicParamsDic = [NSMutableDictionary dictionaryWithDictionary:tracks.firstObject];
    [publicParamsDic removeObjectForKey:@"event_info"];
    [publicParamsDic removeObjectForKey:@"event_id"];
    [publicParamsDic removeObjectForKey:@"session_id"];
    [publicParamsDic removeObjectForKey:@"ctime"];
    
    for (int i = 0; i < tracks.count; i++)
    {
        NSDictionary *evenDic = tracks[i];
        
        NSString *uidStr = [AppContext getInstance].accountManager.myAccount.uid;
        if (uidStr.length == 0)
        {
            uidStr = @"";
        }
         NSString *nameStr = [AppContext getInstance].accountManager.myAccount.nickName;
        if (nameStr.length == 0)
        {
            nameStr = @"";
        }
        
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dataDic setObject:[evenDic objectForKey:@"event_id"] forKey:@"event_id"];
        [dataDic setObject:[evenDic objectForKey:@"event_info"] forKey:@"event_info"];
        [dataDic setObject:uidStr forKey:@"uid"];
        [dataDic setObject:nameStr forKey:@"nick_name"];
        [dataDic setObject:[evenDic objectForKey:@"session_id"] forKey:@"session_id"];
         [dataDic setObject:[evenDic objectForKey:@"ctime"] forKey:@"ctime"];
     
        [dotDatas addObject:dataDic];
    }
    
    
    //在这里把数组格式进行转换
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:publicParamsDic,@"common",dotDatas,@"data",nil];
    
    NSData *jsonData = [NSDictionary JSONRepresentation:dic];
    
    NSData *sendjsonData = [LuuUtils gzipDeflate2:jsonData];
    // NSData *sendjsonData = [LFCGzipUtility  gzipData:jsonData];
    
    [self appendHeader:@"gzip" forKey:@"Content-Encoding"];
    [self appendHeader:@"gzip" forKey:@"Accept-Encoding"];

    [self setBody:sendjsonData];
    
    self.onSuccessed = ^(id result) {
       
//        NSLog(@"======上传成功%ld",(long)self.resStatusCode);
        
//        for (int i = 0; i < tracks.count; i++)
//        {
//            NSDictionary *evenDic = tracks[i];
//            
//            
//            [WLRecordLog writeNo1:@"dot" text:[evenDic objectForKey:@"ctime"]];
////            NSLog(@"已经上传成功的%@",[evenDic objectForKey:@"ctime"]);
//        }
        
        if (successed)
        {
            successed();
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
