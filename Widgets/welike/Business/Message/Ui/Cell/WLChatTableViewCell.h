//
//  WLChatTableViewCell.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIMSession.h"

static NSString *WLChatTableViewCellIdentifier = @"WLChatTableViewCell";

@interface WLChatTableViewCell : UITableViewCell

@property (nonatomic, strong) WLIMSession *session;
@property (nonatomic, assign) BOOL isTail;

- (void)bindChat:(WLIMSession *)session;

@end
