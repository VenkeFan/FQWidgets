//
//  WLSearchResultDisplayViewController.m
//  welike
//
//  Created by gyb on 2018/5/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchResultDisplayViewController.h"
#import "WLContactPersonListTableViewCell.h"
#import "WLContactListViewController.h"
#import "WLContactsManager.h"
#import "WLSearchPersonResultOnlineController.h"
#import "WLPostViewController.h"
#import "WLCommentPostViewController.h"
#import "WLRepostViewController.h"


@interface WLSearchResultDisplayViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIButton *searchOnline;
}
@end

@implementation WLSearchResultDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   

    personListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth ,kScreenHeight - kNavBarHeight - kSafeAreaBottomY - 48) style:UITableViewStylePlain];
    personListView.delegate = self;
    personListView.dataSource = self;
    personListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    personListView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:personListView];

    personListView.estimatedRowHeight = 0;
    personListView.estimatedSectionHeaderHeight = 0;
    personListView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)){
        personListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    
    searchOnline = [UIButton buttonWithType:UIButtonTypeCustom];
    searchOnline.frame = CGRectMake(0, 0, kScreenWidth, 48);
//    searchOnline.backgroundColor = kSearchBtnBg;
    searchOnline.titleLabel.font = kRegularFont(14);
    [searchOnline setTitle:[AppContext getStringForKey:@"contacts_search_contacts_search_online" fileName:@"publish"] forState:UIControlStateNormal];
    [searchOnline setTitleColor:kClickableTextColor forState:UIControlStateNormal];
    [searchOnline addTarget:self action:@selector(searchBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchOnline];
    
    searchOnline.hidden = YES;
}


#pragma mark UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return _friendListArray.count;
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RootCellIdentifier = @"SearchListCell";
    WLContactPersonListTableViewCell *cell = (WLContactPersonListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLContactPersonListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
   
    cell.contact = _friendListArray[indexPath.row];
    cell.searchStr = _searchStr;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[AppContext getInstance].contactsManager atContact:_friendListArray[indexPath.row]];
    
    if ([self select])
    {
        self.select(_friendListArray[indexPath.row]);
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view.superview endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setFriendListArray:(NSMutableArray *)friendListArray
{
    _friendListArray = friendListArray;
    [personListView reloadData];
    
    if (_friendListArray.count == 0)
    {
        searchOnline.hidden = NO;
    }
    else
    {
        searchOnline.hidden = YES;
    }
    
}

-(void)searchBtnPressed
{
   UIViewController *controller = [self.view.superview parentControlloer];
    
    NSString *superMainControllerName = [UIViewController superControllerName:controller.presentingViewController];
 
    if ([superMainControllerName isEqualToString:@"RDRootViewController"])
    {
        RDRootViewController *navController = (RDRootViewController *)controller.presentingViewController;
        NSString *controllerName = [UIViewController superControllerName:navController.topViewController];
        //        NSLog(@"3===%@",controllerName);
        if ([controllerName isEqualToString:@"WLPostViewController"])
        {
            WLPostViewController *postController = (WLPostViewController *)navController.topViewController;
            [WLPublishTrack contactPageSearchOnline:postController.source main_source:postController.mainSource page_type:postController.page_type];
        }

        if ([controllerName isEqualToString:@"WLCommentPostViewController"])
        {
            WLCommentPostViewController *postController = (WLCommentPostViewController *)navController.topViewController;
            [WLPublishTrack contactPageSearchOnline:postController.source main_source:postController.mainSource page_type:postController.page_type];
        }

        if ([controllerName isEqualToString:@"WLRepostViewController"])
        {
            WLRepostViewController *postController = (WLRepostViewController *)navController.topViewController;
            [WLPublishTrack contactPageSearchOnline:postController.source main_source:postController.mainSource page_type:postController.page_type];
        }
    }
    
    
    WLContactListViewController *contactListViewController = (WLContactListViewController *)[self.view.superview parentControlloer];
    
    WLSearchPersonResultOnlineController *searchPersonResultOnlineController = [[WLSearchPersonResultOnlineController alloc] init];
    searchPersonResultOnlineController.searchStr = contactListViewController.searchStr;
    [contactListViewController.navigationController pushViewController:searchPersonResultOnlineController animated:YES];
    
    searchPersonResultOnlineController.select = ^(WLContact *contact) {
        if ([self select])
        {
            self.select(contact);
        }
    };
    
    
 }

@end
