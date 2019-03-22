//
//  WLStatusTrack.h
//  welike
//
//  Created by gyb on 2018/12/21.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WLStatusTrack_from) {
    WLStatusTrack_from_animation                = 1,
    WLStatusTrack_from_status_btn               = 2
};

typedef NS_ENUM(NSInteger, WLStatusTrack_buttontype) {
    WLStatusTrack_buttontype_change_text                = 1,
    WLStatusTrack_buttontype_change_image              = 2,
     WLStatusTrack_buttontype_edit_text               = 3
};


@interface WLStatusTrack : NSObject

+(void)mainBtnInTabBarHasAnimation; //主页面上面的post按钮有动画

+(void)postStatusAppear:(WLStatusTrack_from)satusTrack_from;

+(void)postStatusHasEdited:(WLStatusTrack_buttontype)statusTrack_buttontype;

+(void)postStatusSendPressed:(BOOL)textchanged
                     content:(NSString *)textStr
                     imageId:(NSString *)imageId
                  categoryID:(NSString *)categoryID
                categoryName:(NSString *)categoryName;

+(void)clickDownloadPic;
+(void)selectPic;
+(void)clickEmoji;

@end

NS_ASSUME_NONNULL_END
