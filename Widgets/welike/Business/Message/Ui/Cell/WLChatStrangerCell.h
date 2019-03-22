//
//  WLChatStrangerCell.h
//  welike
//
//  Created by 刘斌 on 2018/5/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIMSession.h"

static NSString *WLChatStrangerCellIdentifier = @"WLChatStrangerCell";

@interface WLChatStrangerCell : UITableViewCell

@property (nonatomic, strong) WLIMSession *session;
@property (nonatomic, assign) BOOL isTail;

- (void)bindChat:(WLIMSession *)session;

@end
