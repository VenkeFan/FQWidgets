//
//  WLShortUrlManager.m
//  welike
//
//  Created by fan qi on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLShortUrlManager.h"
#import "WLShortUrlRequest.h"
#import "WLAccountManager.h"
#import "RDLocalizationManager.h"

NSString * const WLShortUrlShareModeMapping[] = {
    [WLShortUrlShareMode_More]              = @"more",
    [WLShortUrlShareMode_Facebook]          = @"fb",
    [WLShortUrlShareMode_WhatsApp]          = @"wapp",
    [WLShortUrlShareMode_Instagram]         = @"ins",
    [WLShortUrlShareMode_Copy]              = @"copy"
};

@implementation WLShortUrlManager

- (void)loadShortUrlWithShareID:(NSString *)shareID
                      successed:(shortUrlSuccessed)successed
                         failed:(shortUrlFailed)failed {
    if ([AppContext getInstance].accountManager.isLogin) {
        WLShortUrlRequest *request = [[WLShortUrlRequest alloc] init];
        [request fetchShortUrlWithUrlString:[self urlStringWithShareID:shareID]
                                  successed:^(NSString *urlString) {
                                      if (successed) {
                                          successed(urlString);
                                      }
                                  }
                                      error:^(NSInteger errorCode) {
                                          if (failed) {
                                              failed(errorCode);
                                          }
                                      }];
    } else {
        [self exemptLoginUrlStringWithShareID:shareID
                                    successed:successed];
    }
}

- (NSString *)urlStringWithShareID:(NSString *)shareID {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"pid=share"];
    [urlString appendString:[NSString stringWithFormat:@"&c=%@", WLShortUrlShareModeMapping[self.shareUrlMode]]];
    [urlString appendString:[NSString stringWithFormat:@"&af_adset=%ld", (long)self.shareType]];
    [urlString appendString:[NSString stringWithFormat:@"&af_sub1=%@", [AppContext getInstance].accountManager.myAccount.uid]];
    [urlString appendString:[NSString stringWithFormat:@"&af_sub2=%@", shareID ?: @""]];
    [urlString appendString:[NSString stringWithFormat:@"&lang=%@", [[RDLocalizationManager getInstance] getCurrentLanguage]]];
    
    return urlString;
}

- (void)exemptLoginUrlStringWithShareID:(NSString *)shareID
                                    successed:(shortUrlSuccessed)successed {
    /*
     private static final String PATH_POST = "p";
     private static final String PATH_APP = "download";
     private static final String PATH_PROFILE = "profile";
     private static final String PATH_TOPIC = "topic/hot";
     private static final String PATH_LBS = "lbs/hot";
     */
    
    NSString *pathPost = @"p";
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"https://s.welike.in/"];
    [urlString appendString:[NSString stringWithFormat:@"%@/", pathPost]];
    [urlString appendString:shareID];
    
    if (successed) {
        successed(urlString);
    }
}

@end
