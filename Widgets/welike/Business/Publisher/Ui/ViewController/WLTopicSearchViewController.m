//
//  WLTopicSearchViewController.m
//  welike
//
//  Created by gyb on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicSearchViewController.h"
#import "WLTopicSelectCell.h"
#import "WLSearchTopicManager.h"
#import "WLTopicInfoModel.h"
#import "WLHistoryCache.h"
#import "WLSearchTopicViewController.h"
#import "WLTopicSearchSectionView.h"

@interface WLTopicSearchViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewEmptyDelegate,UIScrollViewEmptyDataSource>
{
  
}


 @property (assign,nonatomic) BOOL isSearching;

@property (strong,nonatomic) UITextField *searchField;

@property (strong,nonatomic) NSArray *hotArray;
@property (strong,nonatomic) NSArray *recentlyArray;

@property (strong,nonatomic) UITableView *topicListView;


@property (strong,nonatomic) WLSearchTopicViewController *searchTopicViewController;

 @property (assign,nonatomic) BOOL hasInput;//打点用

@end

@implementation WLTopicSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.title = @"#";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 48)];
    [self.view addSubview:searchView];
    
    _topicListView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight + searchView.height, kScreenWidth ,kScreenHeight - kNavBarHeight - searchView.height -  - kSafeAreaBottomY) style:UITableViewStylePlain];
    _topicListView.delegate = self;
    _topicListView.dataSource = self;
    _topicListView.emptyDelegate = self;
    _topicListView.emptyDataSource = self;
    // personListView.showsVerticalScrollIndicator = NO;
    _topicListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_topicListView];
    
    _topicListView.estimatedRowHeight = 0;
    _topicListView.estimatedSectionHeaderHeight = 0;
    _topicListView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)){
        _topicListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    
    UIImage *searchImage = [AppContext getImageForKey:@"publish_search_frame"];
    UIImage *searchFlag = [AppContext getImageForKey:@"publish_search_topic"];
    
    
    UIImageView *searchBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (48 - searchImage.size.height)/2.0, kScreenWidth - 20, searchImage.size.height)];
    searchBgView.image = [searchImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [searchView addSubview:searchBgView];
    
    UIImageView *searchFlagView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (searchImage.size.height - searchFlag.size.height)/2.0, searchFlag.size.width, searchFlag.size.height)];
    searchFlagView.image = searchFlag;
    [searchBgView addSubview:searchFlagView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, searchView.height - 1, kScreenWidth, 1)];
    lineView.backgroundColor = kSeparateLineColor;
    [searchView addSubview:lineView];
    
    
    NSString *placeHolderStr = [AppContext getStringForKey:@"contacts_search_hint" fileName:@"publish"];
    NSMutableAttributedString *placeHolderString = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
    [placeHolderString addAttribute:NSFontAttributeName value:kRegularFont(14) range:NSMakeRange(0, placeHolderStr.length)];
    
    
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(10 + 33 , (48 - 28)/2.0, searchBgView.width - 33 - 10, 28)];;
    _searchField.delegate = self;
    _searchField.textColor = kSearchTextColor;
    _searchField.tintColor = kMainColor;
    _searchField.returnKeyType = UIReturnKeyDone;
//    _searchField.backgroundColor = [UIColor redColor];
     _searchField.font = kRegularFont(14);
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.attributedPlaceholder = placeHolderString;
    [searchView addSubview:_searchField];
    
    [self refresh];
}

-(void)refresh
{
    __weak typeof(self) weakSelf = self;
    
    WLSearchTopicManager *searchTopicManager = [[WLSearchTopicManager alloc] init];
    
    [searchTopicManager listRecentTopics:^(NSArray *topics, NSInteger errCode) {
        weakSelf.recentlyArray = [NSArray arrayWithArray:topics];
        
        [searchTopicManager listFiveHotTopics:^(NSArray *topics, NSInteger errCode) {
            
            if (errCode == ERROR_SUCCESS)
            {
                weakSelf.hotArray = [NSArray arrayWithArray:topics];
                
                if (weakSelf.hotArray.count +  weakSelf.recentlyArray.count == 0)
                {
                    weakSelf.topicListView.emptyType = WLScrollEmptyType_Empty_Data;
                }
                
                [weakSelf.topicListView reloadData];
                [weakSelf.topicListView reloadEmptyData];
            }
            else
            {
                weakSelf.topicListView.emptyType = WLScrollEmptyType_Empty_Network;
                [weakSelf.topicListView reloadData];
                [weakSelf.topicListView reloadEmptyData];
            }
        }];
    }];
}



#pragma mark UITableView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchField resignFirstResponder];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    NSInteger sectionNum = 0;
    if (_hotArray.count > 0)
    {
        sectionNum += 1;
    }
    if (_recentlyArray.count > 0)
    {
        sectionNum += 1;
    }
    
    return sectionNum;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (_hotArray.count > 0)
        {
            return _hotArray.count;
        }
        else
        {
             return _recentlyArray.count;
        }
    }
    else
    {
        return _recentlyArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hotArray.count > 0)
    {
        if (indexPath.section == 0)
        {
              return 50;
        }
        else
        {
              return 40;
        }
    }
    else
    {
        return 40;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WLTopicSearchSectionView *sectionView = [[WLTopicSearchSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
    if (section == 0)
    {
        if (_hotArray.count > 0)
        {
            sectionView.titleStr = [AppContext getStringForKey:@"sort_trending_text" fileName:@"common"];
        }
        else
        {
            sectionView.titleStr = [AppContext getStringForKey:@"recent_topic_title_text" fileName:@"publish"];
        }
    }
    else
    {
        sectionView.titleStr = [AppContext getStringForKey:@"recent_topic_title_text" fileName:@"publish"];
    }
    
     return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RootCellIdentifier = @"TopicListCell";
    WLTopicSelectCell *cell = (WLTopicSelectCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLTopicSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    if (indexPath.section == 0)
    {
        if (_hotArray.count > 0)
        {
            WLTopicInfoModel *topicInfoModel = [_hotArray objectAtIndex:indexPath.row];
            cell.type = WELIKE_TOPIC_TYPE_hot;
            cell.topicName = topicInfoModel.topicName;
            cell.topicDes = topicInfoModel.desc;
        }
        else
        {
            WLTopicInfoModel *topicInfoModel = [_recentlyArray objectAtIndex:indexPath.row];
            cell.type = WELIKE_TOPIC_TYPE_recently;
            cell.topicName = topicInfoModel.topicName;
        }
    }
    else
    {
          WLTopicInfoModel *topicInfoModel = [_recentlyArray objectAtIndex:indexPath.row];
        cell.type = WELIKE_TOPIC_TYPE_recently;
           cell.topicName = topicInfoModel.topicName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLTopicInfoModel *topicInfoModel;
    if (_hotArray.count > 0)
    {
        if (indexPath.section == 0)
        {
              topicInfoModel = [_hotArray objectAtIndex:indexPath.row];
        }
        else
        {
            topicInfoModel = [_recentlyArray objectAtIndex:indexPath.row];
           // topicInfoModel.topicID = [topicInfoModel.topicName substringFromIndex:1];
        }
    }
    else
    {
        if (_recentlyArray.count > 0)
        {
            topicInfoModel = [_recentlyArray objectAtIndex:indexPath.row];
//            topicInfoModel.topicID = [[_recentlyArray objectAtIndex:indexPath.row] substringFromIndex:1];
        }
    }
    
    topicInfoModel.topic_source = WLTopic_source_recommand_topic;
    
    
    if ([self select])
    {
        self.select(topicInfoModel);
    }

    
    
    WLSearchHistory *topic = [[WLSearchHistory alloc] init];
    topic.keyword = topicInfoModel.topicName;
    topic.time = [[NSDate date] timeIntervalSince1970] * 1000;
    
    
    [WLHistoryCache insert:topic withResultType:WELIKE_SEARCH_HISTORY_TYPE_TOPIC];
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.topicListView.emptyType == WLScrollEmptyType_Empty_Data)
    {
       return [AppContext getStringForKey:@"topic_choice_empty_text" fileName:@"topic"];
    }
    else
    {
        return nil;
    }
}


//- (NSString *)buttonTitleForEmptyDataSource:(UIScrollView *)scrollView
//{
//    if (self.topicListView.emptyType == WLScrollEmptyType_Empty_Data)
//    {
//        return [AppContext getStringForKey:@"common_reload_text" fileName:@"common"];
//    }
//    else
//    {
//        return nil;
//    }
//}

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
     [self refresh];
}


#pragma mark UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    NSLog(@"1=======%lu",textField.text.length);
    //    NSLog(@"2======%lu=====%lu",range.location,range.length);
    
    if (_hasInput == NO)
    {
        _hasInput = YES;
        
        if ([self hasIput])
        {
            self.hasIput();
        }
    }
    
    
    //删完field中的字符处理
    if (string.length == 0 && textField.text.length == range.length)
    {
        if (_searchTopicViewController)
        {
            [_searchTopicViewController.view removeFromSuperview];
            _searchTopicViewController = nil;
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

    //对字符进行处理,包括过滤,和删除前后空格换行等
    NSString *legalSearchKey = [self checkSearchKeyWhetherReasonable:searchString];
    
    if (legalSearchKey.length == 0)
    {
        return NO;
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        
        if (!_searchTopicViewController)
        {
            _searchTopicViewController = [[WLSearchTopicViewController alloc] init];
            _searchTopicViewController.legalSearchKey = legalSearchKey;
            
            _searchTopicViewController.view.frame = CGRectMake(0, kNavBarHeight + 55 , kScreenWidth, kScreenHeight - kNavBarHeight - 55);
            
            _searchTopicViewController.select = ^(WLTopicInfoModel *topicInfo) {

                WLSearchHistory *topic = [[WLSearchHistory alloc] init];
                topic.keyword = topicInfo.topicName;
                topic.time = [[NSDate date] timeIntervalSince1970] * 1000;
                [WLHistoryCache insert:topic withResultType:WELIKE_SEARCH_HISTORY_TYPE_TOPIC];
                
                if ([weakSelf select])
                {
                    weakSelf.select(topicInfo);
                }

                dispatch_async(dispatch_get_main_queue(), ^{

                    [weakSelf dismissViewControllerAnimated:YES
                                                 completion:^{

                                                 }];
                });
            };
            
            [self.view addSubview:_searchTopicViewController.view];
        }
        else
        {
            _searchTopicViewController.legalSearchKey = legalSearchKey;
            
            if (_isSearching == NO)
            {
                _isSearching = YES;
                [_searchTopicViewController research];
                //延时
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
    if (_searchTopicViewController)
    {
        [_searchTopicViewController.view removeFromSuperview];
        _searchTopicViewController = nil;
    }
    
    return YES;
}


//对搜索数据进行预处理
-(NSString *)checkSearchKeyWhetherReasonable:(NSString *)searchStr
{
    NSString *legalSearchKey;
    //去掉头尾空格
    NSString *topicWithoutBlankLeftAndRight = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //含非法字符,去掉空格和换行符后剩余一个字符,含有中文
    if (topicWithoutBlankLeftAndRight.length < 1)
    {
        legalSearchKey = @"";
    }
    else
    {
        //检测是否含有非法字符并去掉
        NSString *trimmedString =  [NSString deleteCharacters:topicWithoutBlankLeftAndRight];
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSArray *arr = [regex matchesInString:trimmedString options:NSMatchingReportCompletion range:NSMakeRange(0, [trimmedString length])];
        arr = [[arr reverseObjectEnumerator] allObjects];
        
        for (NSTextCheckingResult *str in arr)
        {
            trimmedString = [trimmedString stringByReplacingCharactersInRange:[str range] withString:@" "];
        }
        legalSearchKey = trimmedString;
    }
    return legalSearchKey;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
