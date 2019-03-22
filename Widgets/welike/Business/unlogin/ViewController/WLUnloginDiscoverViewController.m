//
//  WLUnloginDiscoverViewController.m
//  welike
//
//  Created by gyb on 2018/8/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnloginDiscoverViewController.h"
#import "WLSearchBar.h"
#import "WLBasicTableView.h"
#import "WLBannerCell.h"
//#import "WLResidentTopicCell.h"
#import "WLTrendingUserCell.h"
//#import "WLTrendingTopicCell.h"
#import "WLDiscoverTableView.h"
#import "WLSearchSugViewController.h"
#import "WLWebViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLUserDetailViewController.h"
#import "WLSearchResultViewController.h"

@interface WLUnloginDiscoverViewController ()<WLSearchBarDelegate>
{
    BOOL isScrollToTop;
    BOOL isScrollToBottom;
    
    
    
}

@property (nonatomic, strong) WLSearchBar *searchBar;
@property (nonatomic, strong) WLDiscoverTableView *containerTableView;
@property (nonatomic, strong)   UIView *statusMaskView;



@end

@implementation WLUnloginDiscoverViewController

-(void)dealloc
{
    NSLog(@"discover controller relasse");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
  
    
    [self layoutUI];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_containerTableView closeView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_containerTableView viewAppear];
}



- (void)layoutUI {

    [self.view addSubview:self.containerTableView];

    self.searchBar = [[WLSearchBar alloc] initWithIcon:@"searchbar_icon" placeholder:[AppContext getStringForKey:@"discover_search_default" fileName:@"search"]];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];

    [self.containerTableView display];
    
    
    _statusMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSystemStatusBarHeight + 1.0)];
    _statusMaskView.backgroundColor = [UIColor whiteColor];
    _statusMaskView.alpha = 0.0;
    [self.view addSubview:_statusMaskView];
}

#pragma mark - WLSearchBarDelegate & UITableViewDataSource

- (void)onClickSearchBar:(WLSearchBar *)searchBar
{
    WLSearchSugViewController *vc = [[WLSearchSugViewController alloc] init];
    [[AppContext rootViewController] pushViewController:vc animated:NO];
}

#pragma mark - FQTabBarControllerProtocol
- (void)refreshViewController {
        [self.containerTableView display];
}



#pragma mark - Getter
- (WLDiscoverTableView *)containerTableView {
    
    __weak typeof(self) weakSelf = self;
    
    if (!_containerTableView) {
        WLDiscoverTableView *tableView = [[WLDiscoverTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabBarHeight) style:UITableViewStyleGrouped];
        _containerTableView = tableView;
        _containerTableView.scrollOffsetYChange = ^(CGFloat value) {
        
            if (weakSelf.containerTableView.contentOffset.y >= -weakSelf.containerTableView.contentInset.top)
            {
                weakSelf.searchBar.transform = CGAffineTransformMakeTranslation(0, -(weakSelf.containerTableView.contentOffset.y + weakSelf.containerTableView.contentInset.top));
            }
            
            CGFloat ratio = (weakSelf.containerTableView.contentOffset.y + weakSelf.containerTableView.contentInset.top) / kSystemStatusBarHeight;
            weakSelf.statusMaskView.alpha = ratio;
        
            
            //NSLog(@"===================%f",weakSelf.containerTableView.contentInset.top);
            
           
//
//            if (ratio >= 1)//&& self->isScrollToTop == NO)
//            {
//                if (self->isScrollToTop == YES)
//                {
//                    return;
//                }
//
//                if ( weakSelf.containerTableView.contentInset.top != kSystemStatusBarHeight)
//                {
//                    NSLog(@"==========执行1");
//                    weakSelf.containerTableView.contentInset = UIEdgeInsetsMake(kSystemStatusBarHeight, 0, 0, 0);
//                    self->isScrollToTop = YES;
//                    self->isScrollToBottom = NO;
//                    return;
//                }
//            }
//
//            if (ratio < 1) //&& self->isScrollToBottom == NO)
//            {
//                if (self->isScrollToBottom == YES)
//                {
//                    return;
//                }
//
//
//                if ( weakSelf.containerTableView.contentInset.top != kNavBarHeight)
//                {
//                      NSLog(@"==========执行2");
//                    weakSelf.containerTableView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0);
//                    self->isScrollToTop = NO;
//                    self->isScrollToBottom = YES;
//                    return;
//                }
//            }
        };
        
        _containerTableView.didSelectTrendingUserCell = ^(NSString *urlStr) {
            WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:urlStr];
             [[AppContext rootViewController] pushViewController:webViewController animated:YES];
        };
        
        _containerTableView.didSelectBanner = ^(NSString *topicID) {
            WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
            [[AppContext rootViewController] pushViewController:ctr animated:YES];
        };
       
        _containerTableView.didSelectSearchKey = ^(NSString *keyStr) {
            WLSearchResultViewController *vc = [[WLSearchResultViewController alloc] init];
            vc.keyword = keyStr;
            [[AppContext rootViewController] pushViewController:vc animated:YES];
        };
        
        
          _containerTableView.didSelectUser= ^(NSString *userID) {
              WLUserDetailViewController *vc = [[WLUserDetailViewController alloc] initWithUserID:userID];
              [[AppContext rootViewController] pushViewController:vc animated:YES];
              
          };
        
    }
    return _containerTableView;
}

@end
