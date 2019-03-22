//
//  WLShareManager.m
//  welike
//
//  Created by fan qi on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLShareManager.h"
#import "WLShortUrlManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "WLLoadingDlg.h"
#import "WLShareViewController.h"
#import "WLTrackerShare.h"

#define kWhatsAppShareBasicUrl               @"whatsapp://"

#define kPreShareDomain                      @"https://pre-m.welike.in/"
#define kShareDomain                         @"https://m.welike.in/"

@interface WLShareManager () <FBSDKSharingDelegate>
{
    FBSDKShareDialog *dialog;
}

@property (nonatomic, strong) WLShareModel *shareModel;

@end

@implementation WLShareManager

#pragma mark - Public

- (void)facebookShareWithShareModel:(WLShareModel *)shareModel {
    self.shareModel = shareModel;
    
    if (shareModel.type == WLShareModelType_WebView || shareModel.type == WLShareModelType_Text) {
        [self p_facebookShareWithLink:shareModel.linkUrl];
    } {
//        [self p_fetchShareLinkWithShareModel:shareModel
//                                shareUrlMode:WLShortUrlShareMode_Facebook
//                             finishedHandler:^(NSString *link) {
//                                 [self p_facebookShareWithLink:link];
//                             }];
        
        NSString *link = [self p_fetchShareLinkWithShareModel:shareModel];
        [self p_facebookShareWithLink:link];
    }
}

- (void)whatsAppShareWithShareModel:(WLShareModel *)shareModel {
    self.shareModel = shareModel;
    
    if (shareModel.type == WLShareModelType_WebView || shareModel.type == WLShareModelType_Text) {
        [self p_whatsAppShareWithLink:shareModel.linkUrl];
    } else {
//        [self p_fetchShareLinkWithShareModel:shareModel
//                                shareUrlMode:WLShortUrlShareMode_WhatsApp
//                             finishedHandler:^(NSString *link) {
//                                 [self p_whatsAppShareWithLink:link];
//                             }];
        
        NSString *link = [self p_fetchShareLinkWithShareModel:shareModel];
        [self p_whatsAppShareWithLink:link];
    }
}

- (void)copyLinkWithShareModel:(WLShareModel *)shareModel {
    self.shareModel = shareModel;
    
//    [self p_fetchShareLinkWithShareModel:shareModel
//                            shareUrlMode:WLShortUrlShareMode_Copy
//                         finishedHandler:^(NSString *link) {
//                             [self p_copyLinkWithLink:link shareModel:shareModel];
//                         }];
    
    NSString *link = [self p_fetchShareLinkWithShareModel:shareModel];
    [self p_copyLinkWithLink:link shareModel:shareModel];
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [WLTrackerShare appendTrackerWithShareModel:self.shareModel
                                        channel:WLTrackerShareChannel_Facebook
                                         result:WLTrackerShareResult_Succeed];
    
    NSString *postId = results[@"postId"];
    if (dialog.mode == FBSDKShareDialogModeFeedBrowser && (postId == nil || [postId isEqualToString:@""])) {
        // 如果使用webview分享的，但postId是空的，
        // 这种情况是用户点击了『完成』按钮，并没有真的分享
    } else {
         [self p_dismiss];
    }
    
   
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    [WLTrackerShare appendTrackerWithShareModel:self.shareModel
                                        channel:WLTrackerShareChannel_Facebook
                                         result:WLTrackerShareResult_Unknow];
    
    [self p_dismiss];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [WLTrackerShare appendTrackerWithShareModel:self.shareModel
                                        channel:WLTrackerShareChannel_Facebook
                                         result:WLTrackerShareResult_Failed];
    
    if (!error)
    {
         dialog.mode = FBSDKShareDialogModeFeedBrowser;
         [dialog show];
    }
    else
    {
         [self p_dismiss];
    }
   
}

#pragma mark - Private

- (NSString *)p_fetchShareLinkWithShareModel:(WLShareModel *)shareModel {
    
#ifdef __WELIKE_TEST_
    NSMutableString *link = [NSMutableString stringWithString:kPreShareDomain];
#else
    NSMutableString *link = [NSMutableString stringWithString:kShareDomain];
#endif

    switch (shareModel.type) {
        case WLShareModelType_Feed:
            [link appendString:@"p/"];
            [link appendString:shareModel.shareID];
            break;
        case WLShareModelType_Profile:
            [link appendString:shareModel.shareID];
            break;
        case WLShareModelType_Topic:
            [link appendString:@"topic/"];
            [link appendString:shareModel.shareID];
            break;
        case WLShareModelType_App:
            [link appendString:@"download"];
            break;
        default:
            break;
    }
    
    return link;
}

- (void)p_fetchShareLinkWithShareModel:(WLShareModel *)shareModel
                          shareUrlMode:(WLShortUrlShareMode)shareUrlMode
                       finishedHandler:(void(^)(NSString *link))finishedHandler {
    WLLoadingDlg *loadingDlg = [[WLLoadingDlg alloc] init];
    [loadingDlg show:kCurrentWindow];
    
    WLShortUrlManager *urlManager = [[WLShortUrlManager alloc] init];
    urlManager.shareUrlMode = shareUrlMode;
    urlManager.shareType = shareModel.type;
    [urlManager loadShortUrlWithShareID:shareModel.shareID
                              successed:^(NSString *urlString) {
                                  [loadingDlg hide];
                                  
                                  if (urlString.length > 0) {
                                      if (finishedHandler) {
                                          finishedHandler(urlString);
                                      }
                                  } else {
                                      [self.currentViewCtr showToastWithNetworkErr:ERROR_NETWORK_RESP_INVALID];
                                  }
                              }
                                 failed:^(NSInteger errorCode) {
                                     [loadingDlg hide];
                                     
                                     [self.currentViewCtr showToastWithNetworkErr:errorCode];
                                 }];
}

- (void)p_facebookShareWithLink:(NSString *)shareLink {
    if (shareLink.length == 0) {
        return;
    }
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:shareLink];

    dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self.currentViewCtr;
    dialog.delegate = self;
    dialog.shareContent = content;
    dialog.mode = FBSDKShareDialogModeNative;
    [dialog show];
}

- (void)p_whatsAppShareWithLink:(NSString *)shareLink {
    if (shareLink.length == 0) {
        return;
    }
    
    NSString * url = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)shareLink, NULL,CFSTR("!*'();:@&=+$,/?%#[]"),kCFStringEncodingUTF8));

    NSString * urlWhats = [NSString stringWithFormat:@"%@send?text=%@", kWhatsAppShareBasicUrl, url];
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    else
    {
        [[AppContext currentViewController] showToast:[NSString stringWithFormat:[AppContext getStringForKey:@"share_not_install" fileName:@"common"],@"whatsapp"]];
    }
    
    [WLTrackerShare appendTrackerWithShareModel:self.shareModel
                                        channel:WLTrackerShareChannel_WhatsApp
                                         result:WLTrackerShareResult_Succeed];
    
    [self p_dismiss];
}

//- (void)p_whatsAppShareWithLink:(NSString *)shareLink title:(NSString *)title {
//    if (!title || !shareLink) {
//        return;
//    }
//
//    UIActivityViewController *ctr = [[UIActivityViewController alloc] initWithActivityItems:@[title, shareLink]
//                                                                      applicationActivities:nil];
//    ctr.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeMail, UIActivityTypeMessage];
//    ctr.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
//
//        [WLTrackerShare appendTrackerWithShareModel:self.shareModel
//                                            channel:WLTrackerShareChannel_WhatsApp
//                                             result:activityError ? WLTrackerShareResult_Failed : WLTrackerShareResult_Succeed];
//
//        [self p_dismiss];
//    };
//    [self.currentViewCtr presentViewController:ctr animated:YES completion:nil];
//}

- (void)p_copyLinkWithLink:(NSString *)link shareModel:(WLShareModel *)shareModel {
//    NSString *shareContent = nil;
//
//    switch (shareModel.type) {
//        case WLShareModelType_Feed: {
//            NSString *title = [NSString stringWithFormat:[AppContext getStringForKey:@"share_title_post" fileName:@"common"], shareModel.title];
//            shareContent = [NSString stringWithFormat:@"%@ %@", title, link];
//        }
//            break;
//        case WLShareModelType_App:
//            shareContent = [NSString stringWithFormat:@"%@ %@", [AppContext getStringForKey:@"share_title_app" fileName:@"common"], link];
//            break;
//        case WLShareModelType_Profile: {
//            NSString *title = [NSString stringWithFormat:[AppContext getStringForKey:@"share_title_profile" fileName:@"common"], shareModel.title];
//            shareContent = [NSString stringWithFormat:@"%@ %@", title, link];
//        }
//            break;
//        case WLShareModelType_Topic: {
//            NSString *title = [NSString stringWithFormat:[AppContext getStringForKey:@"share_title_topic" fileName:@"common"], shareModel.title];
//            shareContent = [NSString stringWithFormat:@"%@ %@", title, link];
//        }
//            break;
//        default:
//            shareContent = link;
//            break;
//    }
    
    [UIPasteboard generalPasteboard].string = link;
    [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"common_share_content_copyed" fileName:@"common"]];
    
    [WLTrackerShare appendTrackerWithShareModel:self.shareModel
                                        channel:WLTrackerShareChannel_Copy
                                         result:WLTrackerShareResult_Succeed];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_dismiss];
    });
}

- (void)p_loadImageWithWithShareModel:(WLShareModel *)shareModel finishedHandler:(void(^)(UIImage *))finishedHandler {
    __block UIImage *img = nil;
    if (shareModel.imgUrl.length > 0) {
        img = [self p_imageWithUrlString:shareModel.imgUrl];
        
        if (!img) {
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:shareModel.imgUrl]
                                                        options:SDWebImageCacheMemoryOnly
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                           
                                                       }
                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                          if (image) {
                                                              img = image;
                                                          } else {
                                                              img = [self p_getAppIcon];
                                                          }
                                                          
                                                          if (finishedHandler) {
                                                              finishedHandler(img);
                                                          }
                                                      }];
        } else {
            if (finishedHandler) {
                finishedHandler(img);
            }
        }
    } else {
        if (finishedHandler) {
            finishedHandler(img);
        }
    }
}

- (void)p_facebookShareWithImage:(UIImage *)image shareModel:(WLShareModel *)shareModel {
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[[FBSDKSharePhoto photoWithImage:image userGenerated:YES]];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.shareContent = content;
    dialog.fromViewController = self.currentViewCtr;
    dialog.mode = FBSDKShareDialogModeNative;
    [dialog show];
}

- (void)p_whatsAppShareWithImage:(UIImage *)image shareModel:(WLShareModel *)shareModel {
    
    if (image) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@app", kWhatsAppShareBasicUrl]]]) {
//            NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
//            [UIImageJPEGRepresentation(image, 1.0) writeToFile:savePath atomically:YES];
//
//            UIDocumentInteractionController *ctr = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
//            ctr.UTI = @"net.whatsapp.image";
////            ctr.delegate = self;
//            [ctr presentOpenInMenuFromRect:CGRectZero inView:self.currentViewCtr.view animated:YES];
            
            
            UIActivityViewController *ctr = [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                                                              applicationActivities:nil];
            ctr.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeMail, UIActivityTypeMessage];
            ctr.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                if (completed) {
                    
                }
            };
            [self.currentViewCtr presentViewController:ctr animated:YES completion:nil];
        }
    } else {
        NSString *whatsString = [NSString stringWithFormat:@"%@send?text=%@", kWhatsAppShareBasicUrl, shareModel.desc];
        NSURL *whatsURL = [NSURL URLWithString:[whatsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL:whatsURL]) {
            [[UIApplication sharedApplication] openURL:whatsURL];
        }
    }
}

- (UIImage *)p_imageWithUrlString:(NSString *)urlString {
    UIImage *img = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:urlString];
    if (!img) {
        img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
    }
    return img;
}

- (UIImage *)p_getAppIcon {
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    UIImage  *image = [UIImage imageNamed:icon];
    
    return image;
}

- (void)p_dismiss {
    [(WLShareViewController *)self.currentViewCtr dismiss];
}

@end
