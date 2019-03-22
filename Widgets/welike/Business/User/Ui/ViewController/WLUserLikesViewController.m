//
//  WLUserLikesViewController.m
//  welike
//
//  Created by fan qi on 2018/12/19.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLUserLikesViewController.h"
#import "WLFeedTableView.h"
#import "WLUserLikePostsProvider.h"

@interface WLUserLikesViewController ()

@property (nonatomic, strong) WLFeedTableView *tableView;
@property (nonatomic, copy) NSString *userID;

@end

@implementation WLUserLikesViewController

- (instancetype)initWithUserID:(NSString *)userID {
    if (self = [super init]) {
        _userID = [userID copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"mute_like" fileName:@"user"];
    
    _tableView = [[WLFeedTableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kNavBarHeight)];
    [_tableView setDataSourceProvider:[WLUserLikePostsProvider new] uid:self.userID];
    [self.view addSubview:_tableView];
    
    [_tableView beginRefresh];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kNavBarHeight);
}

@end
