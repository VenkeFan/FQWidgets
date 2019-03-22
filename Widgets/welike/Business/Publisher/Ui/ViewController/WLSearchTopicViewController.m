//
//  WLSearchTopicViewController.m
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchTopicViewController.h"
#import "WLSearchTopicManager.h"
#import "WLTopicInfoModel.h"
#import "WLTopicSelectCell.h"
#import "WLTopicSearchSectionView.h"

@interface WLSearchTopicViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewEmptyDelegate,UIScrollViewEmptyDataSource>
{
   
    
}
@property (strong,nonatomic) NSArray *recommandArray;

@property (strong,nonatomic) UITableView *searchListView;

@property (strong,nonatomic) NSDictionary *sectionDic;




@end

@implementation WLSearchTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _searchListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth ,kScreenHeight - kNavBarHeight - 55) style:UITableViewStylePlain];
    _searchListView.delegate = self;
    _searchListView.dataSource = self;
    // personListView.showsVerticalScrollIndicator = NO;
    _searchListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchListView.emptyDelegate = self;
    _searchListView.emptyDataSource = self;
    [self.view addSubview:_searchListView];

    _searchListView.estimatedRowHeight = 0;
    _searchListView.estimatedSectionHeaderHeight = 0;
    _searchListView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)){
        _searchListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self refresh];
    
}

-(void)refresh
{
    __weak typeof(self) weakSelf = self;
    
    WLSearchTopicManager *searchTopicManager = [[WLSearchTopicManager alloc] init];
    
    [searchTopicManager listAllRecommondTopics:_legalSearchKey callback:^(NSArray *topics, NSInteger errCode) {
        
        if (errCode == ERROR_SUCCESS)
        {
            if (topics.count == 0)
            {
                weakSelf.searchListView.emptyType = WLScrollEmptyType_Empty_Data;
            }
            
            weakSelf.recommandArray = [NSArray arrayWithArray:topics];
            [weakSelf handleTableSectionLayout];
            [weakSelf.searchListView reloadData];
            [weakSelf.searchListView reloadEmptyData];
        }
        else
        {
            weakSelf.searchListView.emptyType = WLScrollEmptyType_Empty_Network;
            
            [weakSelf.searchListView reloadEmptyData];
            [weakSelf.searchListView reloadData];
        }
        
    }];
}

-(void)handleTableSectionLayout
{
    if (_legalSearchKey.length <= 1)
    {
         if (self.recommandArray.count == 0)
         {
             //显示无结果
             _sectionDic = nil;
         }
        else
        {
            _sectionDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Recommend",@"0", nil];
        }
    }

    if (_legalSearchKey.length > 1)
    {
        if (self.recommandArray.count == 0)
        {
            //显示无结果
            _sectionDic =  [NSDictionary dictionaryWithObjectsAndKeys:@"Add",@"0", nil];

        }
        else
        {
            _sectionDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Add",@"0",@"Recommend",@"1",nil];
        }
    }
}

-(void)research
{
    __weak typeof(self) weakSelf = self;

    WLSearchTopicManager *searchTopicManager = [[WLSearchTopicManager alloc] init];
    
    [searchTopicManager listAllRecommondTopics:_legalSearchKey callback:^(NSArray *topics, NSInteger errCode){

        if (errCode == ERROR_SUCCESS)
        {
            weakSelf.recommandArray = [NSArray arrayWithArray:topics];
            [weakSelf handleTableSectionLayout];
            [weakSelf.searchListView reloadData];
        }
    }];
}

#pragma mark UITableView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view.superview endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return _sectionDic.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[_sectionDic objectForKey:@"0"] isEqualToString:@"Add"])
        {
            return 1;
        }
        else
        //if ([[_sectionDic objectForKey:@"0"] isEqualToString:@"Recommend"])
        {
            return _recommandArray.count;
        }
    }
    else //if (section == 1)
    {
        return _recommandArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[_sectionDic objectForKey:@"0"] isEqualToString:@"Add"])
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WLTopicSearchSectionView *sectionView;
    
    if (section == 0)
    {
        if ([[_sectionDic objectForKey:@"0"] isEqualToString:@"Add"])
        {
           // sectionView.symbolImage = nil;
            
            sectionView = [[WLTopicSearchSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
//            sectionView.backgroundColor = [UIColor redColor];

            sectionView.titleStr = [AppContext getStringForKey:@"new_topic_title" fileName:@"publish"];
            sectionView.desStr = [AppContext getStringForKey:@"with_text_numbers_and_spaces" fileName:@"topic"];
           
        }
        else
        {
            sectionView = [[WLTopicSearchSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
//                 sectionView.backgroundColor = [UIColor blueColor];
      
            sectionView.titleStr = [AppContext getStringForKey:@"recommend_topic_title" fileName:@"publish"];
        }
    }
    else
    {
        sectionView = [[WLTopicSearchSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
//        sectionView.backgroundColor = [UIColor blueColor];
       
        sectionView.titleStr =  [AppContext getStringForKey:@"recommend_topic_title" fileName:@"publish"];
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
        if ([[_sectionDic objectForKey:@"0"] isEqualToString:@"Add"])
        {
            cell.type = WELIKE_TOPIC_TYPE_add;
            cell.topicName = _legalSearchKey;
            cell.compareStr = _legalSearchKey;//_searchStr;
            
            if ([self containKey])
            {
                cell.topicDes = nil;
            }
            else
            {
                cell.topicDes = [AppContext getStringForKey:@"new_topic" fileName:@"topic"];
            }
        }
        else
        {
            WLTopicInfoModel *topicInfoModel = [_recommandArray objectAtIndex:indexPath.row];
            cell.type = WELIKE_TOPIC_TYPE_recommand;
            cell.topicName = topicInfoModel.topicName;
            cell.compareStr = _legalSearchKey;
        }

    }
    else
    {
        WLTopicInfoModel *topicInfoModel = [_recommandArray objectAtIndex:indexPath.row];
        cell.type = WELIKE_TOPIC_TYPE_recommand;
        cell.topicName = topicInfoModel.topicName;
        cell.compareStr = _legalSearchKey;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSString *key;
    
    WLTopicInfoModel *topicInfo = [[WLTopicInfoModel alloc] init];
    
     if (indexPath.section == 0)
     {
         if ([[_sectionDic objectForKey:@"0"] isEqualToString:@"Add"])
         {
             topicInfo.topicID = nil;
             topicInfo.topicName = [NSString stringWithString:_legalSearchKey];
             //key = [NSString stringWithString:_legalSearchKey];
             topicInfo.topic_source = WLTopic_source_searchbar_new;
         }
         else
         {
             topicInfo = [_recommandArray objectAtIndex:indexPath.row];
             topicInfo.topic_source = WLTopic_source_recommand_topic;
         }
     }
     else
     {
         topicInfo = [_recommandArray objectAtIndex:indexPath.row];
         topicInfo.topic_source = WLTopic_source_recommand_topic;
     }
    
    if ([self select])
    {
        self.select(topicInfo);
    }

}


-(BOOL)containKey
{
    for (WLTopicInfoModel *topicInfo in _recommandArray)
    {
        if ([topicInfo.topicName isEqualToString:_legalSearchKey])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (_searchListView.emptyType == WLScrollEmptyType_Empty_Data)
    {
        return [AppContext getStringForKey:@"topic_choice_empty_text" fileName:@"topic"];
    }
    else
    {
        return nil;
    }
}
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    [self refresh];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
