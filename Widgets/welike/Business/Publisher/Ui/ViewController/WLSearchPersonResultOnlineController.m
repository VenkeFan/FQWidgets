//
//  WLSearchPersonResultOnlineController.m
//  welike
//
//  Created by gyb on 2018/5/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchPersonResultOnlineController.h"
#import "WLContactPersonListTableViewCell.h"
#import "WLContactsManager.h"
#import "WLFollowCell.h"


@interface WLSearchPersonResultOnlineController ()


@property (strong,nonatomic)  WLContactsOnlineSearcher *onlineSearcher;

@property (strong,nonatomic) NSMutableArray *searchContacts;

@end

@implementation WLSearchPersonResultOnlineController

- (void)dealloc {
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchContacts = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.navigationBar.title = [AppContext getStringForKey:@"publish_mention_online_list_title" fileName:@"publish"];
    
    [self.navigationBar setLeftBtnImageName:@"common_icon_back"];
    

    self.tableView.disableHeaderRefresh = YES;
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kSafeAreaBottomY);
    self.tableView.emptyDelegate = self;
    self.tableView.emptyDataSource = self;
    
    
    _onlineSearcher = [AppContext getInstance].contactsManager.provideOnlineSearcher;

    
    [self addTarget:self refreshAction:@selector(refresh) moreAction:@selector(refreshFromBottom)];
    
    [self beginRefresh];
    
    
}

#pragma mark - action

-(void)refresh
{
    [_onlineSearcher searchWithKeyword:_searchStr completed:^(NSArray *contact, BOOL last, NSInteger errCode) {
        
          [self endRefresh];
        if (errCode == ERROR_SUCCESS)
        {
            [self->_searchContacts removeAllObjects];
            self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
            [self->_searchContacts addObjectsFromArray:contact];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( contact.count == 0)
                {
                    self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
                }
                
              
                [self.tableView reloadData];
                [self.tableView reloadEmptyData];
            });
        }
        else
        {
            self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
            [self.tableView reloadData];
            [self.tableView reloadEmptyData];
        }
    }];
}

-(void)refreshFromBottom
{
    [_onlineSearcher moreCompleted:^(NSArray *contact, BOOL last, NSInteger errCode) {
        [self.tableView endLoadMore];
        self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        [self->_searchContacts addObjectsFromArray:contact];
  
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *RootCellIdentifier = @"SearchOnlineListCell";

    WLFollowCell *userCell = [tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (userCell == nil)
    {
        userCell = [[WLFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RootCellIdentifier];
        userCell.type = WELIKE_FOLLOW_CELL_TYPE_SEARCH;
    }
    
    [userCell setItemModel:_searchContacts[indexPath.row]];
    
    
    return userCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self select])
    {
        self.select(_searchContacts[indexPath.row]);
    }
}

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    //重新刷新
    [self beginRefresh];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.tableView.emptyType == WLScrollEmptyType_Empty_Data)
    {
         return [AppContext getStringForKey:@"search_no_result" fileName:@"search"];
    }
    else
    {
        return nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
