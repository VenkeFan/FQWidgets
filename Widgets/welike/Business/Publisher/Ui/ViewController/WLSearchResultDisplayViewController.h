//
//  WLSearchResultDisplayViewController.h
//  welike
//
//  Created by gyb on 2018/5/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLContact;
@interface WLSearchResultDisplayViewController : RDBaseViewController
{
    UITableView *personListView;
}


@property (nonatomic,strong) NSMutableArray *friendListArray;
@property (nonatomic,strong) NSString *searchStr;
//@property (nonatomic,copy) void(^closeKeyboard)(void);

@property (nonatomic,copy) void(^select)(WLContact *contact);


@end
