//
//  WLDiscoverTableView.m
//  welike
//
//  Created by gyb on 2018/8/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDiscoverTableView.h"
#import "WLResidentTopicCell.h"
#import "WLTrendingUserCell.h"
#import "WLTrendingTopicCell.h"
#import "WLBannerCell.h"
#import "WLWatchWithoutLoginRequestManager.h"
#import "WLTrendingUserModel.h"
#import "WLTrendingUserScrollView.h"
#import "WLTrendingSearchKeysCell.h"
#import "WLUnloginBannerCell.h"
#import "WLTopicInfoModel.h"
#import "WLPostBase.h"
#import "WLPicPost.h"
#import "WLPicInfo.h"
#import "WLWebViewController.h"

static NSString * const TrendingUserCell = @"TrendingUserCell";
static NSString * const TrendingSerchKeysCell = @"TrendingSerchKeysCell";
static NSString * const BannerCell = @"BannerCell";
static NSString * const TrendingTopicCell = @"TrendingTopicCell";



@interface WLDiscoverTableView ()<WLTrendingSearchKeysCellDelegate,WLUnloginBannerCellDelegate,WLTrendingUserCellDelegate>
{
    WLTrendingUserScrollView *trendingUserScrollView;
}

@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *manager;

@property (nonatomic, strong) WLTrendingUserModel *trendingUserModel;
@property (nonatomic, strong) NSMutableArray *trendingSearches;
@property (nonatomic, strong) NSMutableArray *banners;
@property (nonatomic, strong) NSMutableArray *trendingTopics;

@property (nonatomic, strong) NSMutableDictionary *layoutDic;
@property (nonatomic, strong) NSMutableDictionary *rowCountDic;
@property (nonatomic, strong) NSMutableDictionary *rowTypeDic;

@end


@implementation WLDiscoverTableView

-(void)dealloc
{
        NSLog(@"discover table relasse");
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        
        _layoutDic = [[NSMutableDictionary alloc] init];
        _rowCountDic = [[NSMutableDictionary alloc] init];
        _rowTypeDic  = [[NSMutableDictionary alloc] init];
 
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.showsVerticalScrollIndicator = YES;
        self.sectionHeaderHeight = 25;
        self.sectionFooterHeight = CGFLOAT_MIN;
        self.emptyDelegate = nil;
        self.emptyDataSource = nil;
        
        [self registerClass:[WLTrendingUserCell class] forCellReuseIdentifier:TrendingUserCell];
        [self registerClass:[WLTrendingSearchKeysCell class] forCellReuseIdentifier:TrendingSerchKeysCell];
        [self registerClass:[WLUnloginBannerCell class] forCellReuseIdentifier:BannerCell];
        [self registerClass:[WLTrendingTopicCell class] forCellReuseIdentifier:TrendingTopicCell];
        
        self.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0);
        
        [self addTarget:self refreshAction:@selector(refresh) moreAction:@selector(refreshFromBottom)];
        
    }
    return self;
}

- (void)display
{
    [self beginRefresh];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self caculateSectionMum];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[_rowCountDic objectForKey:[NSNumber numberWithInteger:section]] integerValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    NSInteger sectionCount = [self caculateSectionMum];

    if (section == sectionCount - 1 && _trendingTopics.count > 0)
    {
        return 25;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
     return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:section]] isEqualToString:@"WLTrendingTopicCell"])
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 25)];
        
        view.backgroundColor = kLabelBgColor;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.width, view.height)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = [AppContext getStringForKey:@"topic_trending_topic" fileName:@"common"];
        titleLabel.font = kRegularFont(12);
        titleLabel.textColor = kUIColorFromRGB(0x626262);
        [view addSubview:titleLabel];
        
        CGSize titleSize = [titleLabel.text sizeWithFont:titleLabel.font size:CGSizeMake(view.width, view.height)];
        
        UIImage *flagImage = [AppContext getImageForKey:@"Discover_flag"];
        
        UIImageView *flagFront = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - titleSize.width)/2.0 - 7 - flagImage.size.width, (25 - flagImage.size.height)/2.0, flagImage.size.width, flagImage.size.height)];
        flagFront.image = flagImage;
        [view addSubview:flagFront];
        
        UIImageView *flagBehind = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth + titleSize.width)/2.0 + 7, (25 - flagImage.size.height)/2.0, flagImage.size.width, flagImage.size.height)];
        flagBehind.image = flagImage;
        [view addSubview:flagBehind];
        
        return view;
    }
    
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] isEqualToString:@"WLTrendingTopicCell"])
    {
        WLTopicInfoModel *model = _trendingTopics[indexPath.row];
        NSMutableArray *pics = [self picsFromTopicInfo:model];
        
        if (pics.count > 0)
        {
             CGFloat thumbHeight = (kScreenWidth - 16 - 6*3)/4.0;
            
            return 48 + thumbHeight + 8 + 8;
        }
        else
        {
            return 62;
        }
    }
    else
    {
        CGFloat height = [[_layoutDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] floatValue];
        
        return height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] isEqualToString:@"WLTrendingUserCell"])
    {
        WLTrendingUserCell *cell = [tableView dequeueReusableCellWithIdentifier:TrendingUserCell];

        cell.trendingUserModel = _trendingUserModel;
        cell.delegate = self;
        return cell;

    }
    else
        if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] isEqualToString:@"WLTrendingSearchKeysCell"])
        {
            WLTrendingSearchKeysCell *cell = [tableView dequeueReusableCellWithIdentifier:TrendingSerchKeysCell];
            cell.dataArray = _trendingSearches;
            cell.delegate = self;
            return cell;
        }
        else
            if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] isEqualToString:@"WLUnloginBannerCell"])
            {
                WLUnloginBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:BannerCell];
                cell.delegate = self;
                cell.banners = _banners;
                return cell;
            }
            else
            {
//                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TrendingTopicCell];
                WLTrendingTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:TrendingTopicCell];
                cell.model = _trendingTopics[indexPath.row];
                return cell;
            }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] isEqualToString:@"WLTrendingUserCell"])
    {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",[AppContext getHostName],_trendingUserModel.forwardUrl];
        
        if ([self didSelectTrendingUserCell])
        {
            self.didSelectTrendingUserCell(urlStr);
        }
    }
    
    if ([[_rowTypeDic objectForKey:[NSNumber numberWithInteger:indexPath.section]] isEqualToString:@"WLTrendingTopicCell"])
    {
       WLTopicInfoModel *model = _trendingTopics[indexPath.row];

        if ([self didSelectBanner])
        {
            self.didSelectBanner(model.topicID);
        }
    }
    
    

}

-(NSInteger)caculateSectionMum
{
    NSInteger count = 0;
    
    if (_trendingUserModel.users.count > 0)
    {
        count++;
        [_layoutDic setObject:[NSNumber numberWithFloat:100] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowCountDic setObject:[NSNumber numberWithFloat:1] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowTypeDic setObject:@"WLTrendingUserCell" forKey:[NSNumber numberWithInteger:count -1]];
    }
    
    if (_trendingSearches.count > 0)
    {
        count++;
        [_layoutDic setObject:[NSNumber numberWithFloat:110] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowCountDic setObject:[NSNumber numberWithFloat:1] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowTypeDic setObject:@"WLTrendingSearchKeysCell" forKey:[NSNumber numberWithInteger:count -1]];
    }
    
    if (_banners.count > 0)
    {
        count++;
        [_layoutDic setObject:[NSNumber numberWithFloat:120] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowCountDic setObject:[NSNumber numberWithFloat:1] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowTypeDic setObject:@"WLUnloginBannerCell" forKey:[NSNumber numberWithInteger:count -1]];
    }
    

    if (_trendingTopics.count > 0)
    {
        count++;

        [_rowCountDic setObject:[NSNumber numberWithFloat:_trendingTopics.count] forKey:[NSNumber numberWithInteger:count -1]];
        [_rowTypeDic setObject:@"WLTrendingTopicCell" forKey:[NSNumber numberWithInteger:count -1]];
    }

    return count;
}

//当页面隐藏时调用,有计时器需要停止
-(void)closeView
{
    NSArray *dicValues = [_rowTypeDic allKeys];

    for (int i = 0; i < dicValues.count; i++)
    {
        NSString *str =  [_rowTypeDic objectForKey:dicValues[i]];
        if ([str isEqualToString:@"WLUnloginBannerCell"])
        {
            WLUnloginBannerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[dicValues[i] integerValue]]];
            
            [cell.carousel controllerWillDisAppear];
        }
        
    }
}

//当页面显示时调用,有计时器需要停止
-(void)viewAppear
{
    NSArray *dicValues = [_rowTypeDic allKeys];
    
    for (int i = 0; i < dicValues.count; i++)
    {
        NSString *str =  [_rowTypeDic objectForKey:dicValues[i]];
        if ([str isEqualToString:@"WLUnloginBannerCell"])
        {
            WLUnloginBannerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[dicValues[i] integerValue]]];
            
            [cell.carousel controllerWillAppear];
        }
        
    }
}


-(void)refresh
{
      __weak typeof(self) weakSelf = self;
    dispatch_group_t taskGroup = dispatch_group_create();
    
    [self fetchTendingUsers:taskGroup];
    
    [self fetchTrendingSearchKeys:taskGroup];
    
//    [self fetchBanner:taskGroup];
    
    [self fetchTrendingTopics:taskGroup];
    
    dispatch_group_notify(taskGroup, dispatch_get_main_queue(), ^{
      
        self->trendingUserScrollView.dataArray = weakSelf.trendingUserModel.users;
        
        //计算table显示的数据
        [self caculateSectionMum];
        
        [self endRefresh];
        
        [self reloadData];
    });
}

-(void)refreshFromBottom
{
    [self.manager listTrendingTopics:^(NSArray *items, BOOL isLast, NSInteger errCode) {
        
        if (errCode == ERROR_SUCCESS)
        {
            [self.trendingTopics addObjectsFromArray:items];
        }
        else {
            self.refreshFooterView.result = WLRefreshFooterResult_Error;
            return;
        }
        
        //计算table显示的数据
         self.refreshFooterView.result = isLast ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        
        [self caculateSectionMum];
        
        [self endLoadMore];
        
        [self reloadData];
        
    } isRefreshFromTop:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [super scrollViewDidScroll:self];

//    if (_isForceManualRefresh == YES && [scrollView isEqual:self.containerTableView]) {
//        return;
//    }
//
//    if (self.isScrollToSegmentedCtr) {
//        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
//        return;
//    }
//
    
//    if (scrollView.contentOffset.y >= kNavBarHeight)
//    {
////        self.contentOffset = CGPointMake(0, 177 - 44);
//    }
//    else
    {
           if (scrollView.contentOffset.y >= -scrollView.contentInset.top)
           {
               if (self.scrollOffsetYChange)
               {
                   self.scrollOffsetYChange(scrollView.contentOffset.y);
               }
           }
    }
}

- (WLWatchWithoutLoginRequestManager *)manager {
    if (!_manager) {
        _manager = [[WLWatchWithoutLoginRequestManager alloc] init];
    }
    return _manager;
}




- (void)fetchTendingUsers:(dispatch_group_t)group {
  
    __weak typeof(self) weakSelf = self;
  
    dispatch_group_enter(group);

    [self.manager listTrendingUsers:^(WLTrendingUserModel *model, NSString *forwardUrl, NSInteger errCode) {
        
        if (errCode == ERROR_SUCCESS)
        {
            weakSelf.trendingUserModel = model;
        }
          dispatch_group_leave(group);
    }];
}


- (void)fetchTrendingSearchKeys:(dispatch_group_t)group
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_group_enter(group);
    
    [self.manager listTrendingSearchKeys:^(NSArray *items, NSInteger errCode) {
      
        if (errCode == ERROR_SUCCESS)
        {
            weakSelf.trendingSearches = [NSMutableArray arrayWithArray:items];
        }
        dispatch_group_leave(group);
    }];
}


- (void)fetchBanner:(dispatch_group_t)group
{
    __weak typeof(self) weakSelf = self;
    
     dispatch_group_enter(group);
    
    [self.manager listUnloginBanner:^(NSArray *items, NSInteger errCode) {
       
        if (errCode == ERROR_SUCCESS)
        {
            weakSelf.banners = [NSMutableArray arrayWithArray:items];
        }
        dispatch_group_leave(group);
    }];
}
    
    
    
- (void)fetchTrendingTopics:(dispatch_group_t)group
{
    __weak typeof(self) weakSelf = self;
    
     dispatch_group_enter(group);
    
    [self.manager listTrendingTopics:^(NSArray *items, BOOL isLast, NSInteger errCode) {
        
        if (errCode == ERROR_SUCCESS)
        {
            weakSelf.trendingTopics = [NSMutableArray arrayWithArray:items];
        }
        
        weakSelf.refreshFooterView.result = isLast ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        
        
        dispatch_group_leave(group);
        
    } isRefreshFromTop:YES];
}

- (NSMutableArray *)trendingTopics {
    if (!_trendingTopics) {
        _trendingTopics = [NSMutableArray array];
    }
    return _trendingTopics;
}


-(NSMutableArray *)picsFromTopicInfo:(WLTopicInfoModel *)model {
    
    NSMutableArray *pics = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < model.postArray.count; i++)
    {
        WLPostBase *post = model.postArray[i];
        
        if ([post isKindOfClass:[WLPicPost class]])
        {
            WLPicPost *picPost = (WLPicPost *)post;
            
              for (int j = 0; j < picPost.picInfoList.count; j++)
              {
                  WLPicInfo *info = picPost.picInfoList[j];
                  if (info.picUrl.length != 0)
                  {
                      [pics addObject:info.picUrl];
                  }
              }
        }
    }

    return pics;
}

#pragma mark - WLTrendingSearchKeysCellDelegate
- (void)didClickKey:(NSString *)searchKey
{
    if ([self didSelectSearchKey])
    {
        self.didSelectSearchKey(searchKey);
    }
}


- (void)didSelctbanner:(NSString *)topicID
{
//    if ([self didSelectBanner])
//    {
//        self.didSelectBanner(topicID);
//    }
}

- (void)didSelctUser:(NSString *)userID
{
    if ([self didSelectUser])
    {
        self.didSelectUser(userID);
    }
}





@end
