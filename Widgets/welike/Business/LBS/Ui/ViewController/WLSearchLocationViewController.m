//
//  WLSearchLocationViewController.m
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchLocationViewController.h"
#import "WLLocationCell.h"
#import "WLLocationManager.h"
#import "RDLocation.h"
#import "WLLocationInfo.h"
#import "WLFilterSearchViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface WLSearchLocationViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewEmptyDelegate,UIScrollViewEmptyDataSource,CLLocationManagerDelegate>
{
  
}


@property (assign,nonatomic) BOOL isSearching;
@property (strong,nonatomic) NSMutableArray  *positionListArray;
@property (strong,nonatomic) UITextField *searchField;
//@property (strong,nonatomic) WLBasicTableView *positionTableView;

@property (strong,nonatomic) WLLocationManager *locationManager;

@property (strong,nonatomic) WLFilterSearchViewController *filterSearchViewController;


@property (nonatomic,strong ) CLLocationManager *receiveLocationManager;
@property (nonatomic,assign)    CGFloat strLatitude;//经度
@property (nonatomic,assign)    CGFloat strLongitude;//维度

@property (assign,nonatomic) CLLocationCoordinate2D coordinate;


@end

@implementation WLSearchLocationViewController

-(void)dealloc
{
    NSLog(@"dealloc - WLSearchLocationViewController ");
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationBar.title = [AppContext getStringForKey:@"location_select_title" fileName:@"location"];
    
    _positionListArray = [[NSMutableArray alloc] initWithCapacity:0];
     _locationManager = [WLLocationManager alloc];
    
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 55)];
    [self.view addSubview:searchView];
    
    UIImage *searchImage = [AppContext getImageForKey:@"publish_search_frame"];
    UIImage *searchFlag = [AppContext getImageForKey:@"location_search"];
    
    
    UIImageView *searchBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (searchView.height - searchImage.size.height)/2.0, kScreenWidth - 20, searchImage.size.height)];
    searchBgView.image = [searchImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [searchView addSubview:searchBgView];
    
    UIImageView *searchFlagView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (searchImage.size.height - searchFlag.size.height)/2.0, searchFlag.size.width, searchFlag.size.height)];
    searchFlagView.image = searchFlag;
    [searchBgView addSubview:searchFlagView];
    
    NSString *placeHolderStr =  [AppContext getStringForKey:@"location_search_edit_text_hint" fileName:@"location"];
    NSMutableAttributedString *placeHolderString = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
    [placeHolderString addAttribute:NSFontAttributeName value:kRegularFont(14) range:NSMakeRange(0, placeHolderStr.length)];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, searchView.height - 1, kScreenWidth, 1)];
    lineView.backgroundColor = kSeparateLineColor;
    [searchView addSubview:lineView];

    
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(10 + 33 , (searchView.height - 35)/2.0, searchBgView.width - 33 - 15, 35)];;
    _searchField.delegate = self;
    _searchField.textColor = kSearchTextColor;
    _searchField.tintColor = kMainColor;
    _searchField.returnKeyType = UIReturnKeyDone;
    _searchField.font = kRegularFont(14);
     _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.attributedPlaceholder = placeHolderString;
    [searchView addSubview:_searchField];
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight + 55, kScreenWidth ,kScreenHeight - kNavBarHeight - kSafeAreaBottomY - 55);
    self.tableView.emptyDelegate = self;
    self.tableView.emptyDataSource = self;
    self.tableView.disableHeaderRefresh = YES;
    
    [self addTarget:self refreshAction:@selector(refresh) moreAction:@selector(refreshFromBottom)];
    
    
    [self locatemap];
}

- (void)locatemap{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        _receiveLocationManager = [[CLLocationManager alloc]init];
        _receiveLocationManager.delegate = self;
        [_receiveLocationManager requestWhenInUseAuthorization];
        _receiveLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _receiveLocationManager.distanceFilter = 5.0;
        [_receiveLocationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error description]);
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        
    }
    else
    {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Location;
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
        
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [_receiveLocationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    _strLatitude = currentLocation.coordinate.latitude;
    _strLongitude = currentLocation.coordinate.longitude;
    
    _coordinate = CLLocationCoordinate2DMake(_strLatitude, _strLongitude);
    
    [self beginRefresh];
}

-(void)refresh
{
    __weak typeof(self) weakSelf = self;
    
    [_locationManager listNearbyLocations:_coordinate result:^(NSArray *locations, BOOL last, NSInteger errCode) {
        
          [self endRefresh];
        
        if (errCode == ERROR_SUCCESS)
        {
            if (locations.count == 0)
            {
                weakSelf.tableView.emptyType = WLScrollEmptyType_Empty_Location;
            }
            
            weakSelf.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
            [weakSelf.positionListArray addObjectsFromArray:locations];
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
    [_locationManager listNearbyLocationsFromBottom:_coordinate result:^(NSArray *locations, BOOL last, NSInteger errCode) {
       
        [weakSelf.tableView endLoadMore];
        
        weakSelf.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        [weakSelf.positionListArray addObjectsFromArray:locations];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

#pragma mark UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _positionListArray.count;
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RootCellIdentifier = @"WLLocationCell";
    WLLocationCell *cell = (WLLocationCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLLocationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.locationInfo = _positionListArray[indexPath.row];
    cell.searchStr = @"";
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLLocationInfo *info = _positionListArray[indexPath.row];
    
    
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
    [_searchField resignFirstResponder];
}


#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    if (scrollView.emptyType == WLScrollEmptyType_Empty_Network)
    {
        [self refresh];
    }
    
    if (scrollView.emptyType == WLScrollEmptyType_Empty_Location)
    {
        [self locatemap];
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

#pragma mark UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    NSLog(@"1=======%lu",textField.text.length);
    //    NSLog(@"2======%lu=====%lu",range.location,range.length);
    //删完field中的字符处理
    if (string.length == 0 && textField.text.length == range.length)
    {
        if (_filterSearchViewController)
        {
            [_filterSearchViewController.view removeFromSuperview];
            _filterSearchViewController = nil;
        }
        return YES;
    }
    
    //此处得到输入的字符串
    NSString *searchString;
    
    if (range.length > 0)
    {
        searchString = [NSString stringWithString:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    }
    else
    {
        searchString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    
    if (searchString.length > 32)
    {
        return NO;
    }
    
    if (searchString.length > 0)
    {
        __weak typeof(self) weakSelf = self;
        
        if (!_filterSearchViewController)
        {
            _filterSearchViewController = [[WLFilterSearchViewController alloc] init];
            _filterSearchViewController.navigationBar.hidden = YES;
            _filterSearchViewController.searchStr = searchString;
            _filterSearchViewController.coordinate = _coordinate;
            _filterSearchViewController.view.frame = CGRectMake(0, kNavBarHeight + 55 , kScreenWidth, kScreenHeight - kNavBarHeight - 55 - kSafeAreaBottomY);

            _filterSearchViewController.select = ^(RDLocation *location) {

                if ([weakSelf select])
                {
                    weakSelf.select(location);
                }

                dispatch_async(dispatch_get_main_queue(), ^{

                    [weakSelf dismissViewControllerAnimated:YES
                                                 completion:^{

                                                 }];
                });
            };
            
            [self.view addSubview:_filterSearchViewController.view];
        }
        else
        {
            _filterSearchViewController.searchStr = searchString;
      
            if (_isSearching == NO)
            {
                _isSearching = YES;
                [_filterSearchViewController research];
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Search_DELAY * NSEC_PER_MSEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    weakSelf.isSearching = NO;
                });
            }
        }
                               
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (_filterSearchViewController)
    {
        [_filterSearchViewController.view removeFromSuperview];
        _filterSearchViewController = nil;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
      [_searchField resignFirstResponder];
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
