//
//  WLFilterSearchViewController.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFilterSearchViewController.h"
#import "WLLocationManager.h"
#import "RDLocation.h"
#import "WLLocationCell.h"
#import "WLLocationInfo.h"

@interface WLFilterSearchViewController ()

@property (strong,nonatomic) NSMutableArray *recommandArray;
@property (strong,nonatomic) WLLocationManager *locationManager;

@end

@implementation WLFilterSearchViewController

-(void)dealloc
{
    NSLog(@"dealloc - WLFilterSearchViewController ");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recommandArray = [[NSMutableArray alloc] initWithCapacity:0];
    _locationManager = [WLLocationManager alloc];

    
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth ,kScreenHeight - kNavBarHeight - kSafeAreaBottomY - 55);
    self.tableView.emptyDelegate = self;
    self.tableView.emptyDataSource = self;
    self.tableView.disableHeaderRefresh = YES;
    
    [self addTarget:self refreshAction:@selector(refresh) moreAction:@selector(refreshFromBottom)];
    
    [self beginRefresh];
    
}

-(void)refresh
{
    __weak typeof(self) weakSelf = self;
    
    [_locationManager listSearchLocations:_coordinate key:_searchStr result:^(NSArray *locations, BOOL last, NSInteger errCode) {

        [self endRefresh];

        if (errCode == ERROR_SUCCESS)
        {
            if (locations.count == 0)
            {
                weakSelf.tableView.emptyType = WLScrollEmptyType_Empty_Location;
            }

            weakSelf.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
            [weakSelf.recommandArray addObjectsFromArray:locations];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView reloadEmptyData];
        }
        else
        {
            weakSelf.tableView.emptyType = WLScrollEmptyType_Empty_Data;
            [weakSelf.tableView reloadData];
            [weakSelf.tableView reloadEmptyData];
        }
    }];
}

-(void)refreshFromBottom
{
    __weak typeof(self) weakSelf = self;
    [_locationManager listSearchLocationsFromBottom:_coordinate key:_searchStr result:^(NSArray *locations, BOOL last, NSInteger errCode) {

        [weakSelf.tableView endLoadMore];
        weakSelf.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        [weakSelf.recommandArray addObjectsFromArray:locations];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}


-(void)research
{
    //如果正在执行,则取消,在请求体内执行了
    [_recommandArray removeAllObjects];
    [self.tableView reloadData];
    
     [self beginRefresh];
}

#pragma mark UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recommandArray.count;
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RootCellIdentifier = @"WLLocationRecommandCell";
    WLLocationCell *cell = (WLLocationCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLLocationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
  
    cell.locationInfo = _recommandArray[indexPath.row];
    cell.searchStr = _searchStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLLocationInfo *info = _recommandArray[indexPath.row];
    
    
    RDLocation *location = [[RDLocation alloc] init];
    location.latitude = info.lat;
    location.longitude = info.lng;
    location.placeId = info.placeId;
    location.place = info.name;
    
    if ([self select])
    {
        self.select(location);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view.superview endEditing:YES];
}


#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    if (scrollView.emptyType == WLScrollEmptyType_Empty_Network || scrollView.emptyType == WLScrollEmptyType_Empty_Location)
    {
        [self refresh];
    }
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (scrollView.emptyType == WLScrollEmptyType_Empty_Location)
    {
        return [AppContext getStringForKey:@"no_location_found" fileName:@"location"];
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
