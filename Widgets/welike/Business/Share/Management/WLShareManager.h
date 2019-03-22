//
//  WLShareManager.h
//  welike
//
//  Created by fan qi on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLShareModel.h"

@interface WLShareManager : NSObject

@property (nonatomic, weak) RDBaseViewController *currentViewCtr;

- (void)facebookShareWithShareModel:(WLShareModel *)shareModel;
- (void)whatsAppShareWithShareModel:(WLShareModel *)shareModel;
- (void)copyLinkWithShareModel:(WLShareModel *)shareModel;

@end
