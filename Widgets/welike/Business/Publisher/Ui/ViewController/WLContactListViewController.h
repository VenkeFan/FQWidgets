//
//  WLAboutPersonViewController.h
//  welike
//
//  Created by gyb on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLContact;
@interface WLContactListViewController : WLNavBarBaseViewController
{
    UITableView *personListView;
  
}

@property (nonatomic,copy) void(^select)(WLContact *contact);



-(NSString *)searchStr;

@end
