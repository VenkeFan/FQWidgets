//
//  WLChatBoxCell.h
//  welike
//
//  Created by luxing on 2018/6/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIMSession.h"

#define MENTION_SESSION_SID             @"001"
#define COMMENT_SESSION_SID             @"002"
#define LIKE_SESSION_SID                @"003"

static NSString *WLChatBoxCellIdentifier = @"WLChatBoxCell";

@interface WLChatBoxCell : UITableViewCell

@property (nonatomic, strong) WLIMSession *session;
@property (nonatomic, assign) BOOL isTail;

- (void)bindChat:(WLIMSession *)session;

@end
