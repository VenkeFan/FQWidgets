//
//  WLAboutPersonViewController.m
//  welike
//
//  Created by gyb on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLContactListViewController.h"
#import "WLContactPersonListTableViewCell.h"
#import "WLSearchResultDisplayViewController.h"
#import "WLContactsManager.h"
#import "WLMaskView.h"
#import "WLPostViewController.h"
#import "WLCommentPostViewController.h"
#import "WLRepostViewController.h"


@interface WLContactListViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
   // WLSearchResultDisplayViewController *resultController;
    UIButton *searchOnline ;
    
    BOOL isInput; //打点用
}

//@property (strong,nonatomic)  UISearchController *searchController;

@property (strong,nonatomic) NSString *searchString;
@property (strong,nonatomic) WLMaskView *maskView;

@property (strong,nonatomic) NSMutableArray *friendListArray;
@property (strong,nonatomic) NSMutableArray *filteredUserList;


@property (strong,nonatomic) UITextField *searchField;

@property (strong,nonatomic) WLSearchResultDisplayViewController *resultController;

@end

@implementation WLContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationBar.title = @"@";
    
    _friendListArray = [[NSMutableArray alloc] initWithCapacity:0];
    _filteredUserList = [[NSMutableArray alloc] initWithCapacity:0];

    personListView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth ,kScreenHeight - kNavBarHeight - kSafeAreaBottomY) style:UITableViewStylePlain];
    personListView.delegate = self;
    personListView.dataSource = self;
   // personListView.showsVerticalScrollIndicator = NO;
    personListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:personListView];

    personListView.estimatedRowHeight = 0;
    personListView.estimatedSectionHeaderHeight = 0;
    personListView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)){
        personListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 48)];
   // searchView.backgroundColor = searchBarBg;

    personListView.tableHeaderView = searchView;


    UIImage *searchImage = [AppContext getImageForKey:@"publish_search_frame"];
    UIImage *searchFlag = [AppContext getImageForKey:@"search_sug_sug"];


    UIImageView *searchBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (searchView.height - searchImage.size.height)/2.0, kScreenWidth - 20, searchImage.size.height)];
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
    
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(10 + 33 , (searchView.height - 28)/2.0, searchBgView.width - 33 - 15, 28)];;
    _searchField.delegate = self;
    _searchField.textColor = kSearchTextColor;
    _searchField.tintColor = kMainColor;
    _searchField.returnKeyType = UIReturnKeyDone;
    _searchField.font = kRegularFont(14);
    _searchField.attributedPlaceholder = placeHolderString;
    [searchView addSubview:_searchField];
    
      __weak typeof(self) weakSelf = self;
    [[AppContext getInstance].contactsManager listAllContacts:^(NSArray *contact) {

        weakSelf.friendListArray =  [NSMutableArray arrayWithArray:contact];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->personListView reloadData];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
   //dot
    NSString *superMainControllerName = [UIViewController superControllerName:self.presentingViewController];
    //NSInteger mainControllerIndex = [AppContext mainViewController].selectedIndex;
    
    if ([superMainControllerName isEqualToString:@"RDRootViewController"])
    {
        RDRootViewController *navController = (RDRootViewController *)self.presentingViewController;
        NSString *controllerName = [UIViewController superControllerName:navController.topViewController];
//        NSLog(@"3===%@",controllerName);
        if ([controllerName isEqualToString:@"WLPostViewController"])
        {
            WLPostViewController *postController = (WLPostViewController *)navController.topViewController;
            [WLPublishTrack contactPageAppear:postController.source main_source:postController.mainSource page_type:postController.page_type];
        }
        
        if ([controllerName isEqualToString:@"WLCommentPostViewController"])
        {
            WLCommentPostViewController *postController = (WLCommentPostViewController *)navController.topViewController;
            [WLPublishTrack contactPageAppear:postController.source main_source:postController.mainSource page_type:postController.page_type];
        }
        
        if ([controllerName isEqualToString:@"WLRepostViewController"])
        {
            WLRepostViewController *postController = (WLRepostViewController *)navController.topViewController;
            [WLPublishTrack contactPageAppear:postController.source main_source:postController.mainSource page_type:postController.page_type];
        }
    }

    [super viewDidAppear:animated];
}




#pragma mark UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return self.friendListArray.count;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
          return [_friendListArray[0] count];
    }
    else
    {
         return [_friendListArray[1] count];
    }
}

- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.friendListArray.count == 2)
        {
            UIView *signView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 40)];
                signView.backgroundColor = [UIColor whiteColor];
            
            UIView *lightView = [[UIView alloc] initWithFrame:CGRectMake(-4, (signView.height - 16)/2.0, 8, 16)];
            lightView.backgroundColor = kMainColor;
            lightView.layer.cornerRadius = 3;
            lightView.clipsToBounds = YES;
            [signView addSubview:lightView];
            
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kScreenWidth - 8, 40)];
            promptLabel.textColor = kNameFontColor;
            promptLabel.font = kBoldFont(14);
            promptLabel.text = [AppContext getStringForKey:@"post_recent_contacts" fileName:@"publish"];
            [signView addSubview:promptLabel];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12, 39, kScreenWidth, 1)];
            lineView.backgroundColor = kSeparateLineColor;
            [signView addSubview:lineView];
            
            return signView;
        }
        else
        {
            UIView *signView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 40)];
                 signView.backgroundColor = [UIColor whiteColor];
            
            UIView *lightView = [[UIView alloc] initWithFrame:CGRectMake(-4, (signView.height - 16)/2.0, 8, 16)];
            lightView.backgroundColor = kMainColor;
            lightView.layer.cornerRadius = 3;
            lightView.clipsToBounds = YES;
            [signView addSubview:lightView];
            
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kScreenWidth - 8, 40)];
            promptLabel.textColor = kNameFontColor;
            promptLabel.font = kBoldFont(14);
            promptLabel.text =  [AppContext getStringForKey:@"post_all_contact" fileName:@"publish"];
            [signView addSubview:promptLabel];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12, 39, kScreenWidth, 1)];
            lineView.backgroundColor = kSeparateLineColor;
            [signView addSubview:lineView];

            return signView;
        }
        
    }
    else
    {
        UIView *signView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 40)];
        signView.backgroundColor = [UIColor whiteColor];

        UIView *lightView = [[UIView alloc] initWithFrame:CGRectMake(-4, (signView.height - 16)/2.0, 8, 16)];
        lightView.backgroundColor = kMainColor;
        lightView.layer.cornerRadius = 3;
        lightView.clipsToBounds = YES;
        [signView addSubview:lightView];
    
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kScreenWidth - 8, 40)];
        promptLabel.textColor = kNameFontColor;
        promptLabel.font = kBoldFont(14);
         promptLabel.text =  [AppContext getStringForKey:@"post_all_contact" fileName:@"publish"];
        [signView addSubview:promptLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12, 39, kScreenWidth, 1)];
        lineView.backgroundColor = kSeparateLineColor;
        [signView addSubview:lineView];
        
        return signView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RootCellIdentifier = @"AboutListCell";
    WLContactPersonListTableViewCell *cell = (WLContactPersonListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLContactPersonListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0)
    {
         cell.contact = _friendListArray[0][indexPath.row];
    }
    else
    {
         cell.contact = _friendListArray[1][indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self select])
    {
        self.select(_friendListArray[indexPath.section][indexPath.row]);
    }
    
    [[AppContext getInstance].contactsManager atContact:_friendListArray[indexPath.section][indexPath.row]];
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _searchField)
    {
        return NO;
    }
    return YES;
}

-(void)closeBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (isInput == NO)
    {
        isInput  = YES;
        
        NSString *superMainControllerName = [UIViewController superControllerName:self.presentingViewController];
        //NSInteger mainControllerIndex = [AppContext mainViewController].selectedIndex;
        
        if ([superMainControllerName isEqualToString:@"RDRootViewController"])
        {
            RDRootViewController *navController = (RDRootViewController *)self.presentingViewController;
            NSString *controllerName = [UIViewController superControllerName:navController.topViewController];
            //        NSLog(@"3===%@",controllerName);
            if ([controllerName isEqualToString:@"WLPostViewController"])
            {
                WLPostViewController *postController = (WLPostViewController *)navController.topViewController;
                 [WLPublishTrack contactPageInput:postController.source main_source:postController.mainSource page_type:postController.page_type];
            }
            
            if ([controllerName isEqualToString:@"WLCommentPostViewController"])
            {
                WLCommentPostViewController *postController = (WLCommentPostViewController *)navController.topViewController;
                [WLPublishTrack contactPageInput:postController.source main_source:postController.mainSource page_type:postController.page_type];
            }
            
            if ([controllerName isEqualToString:@"WLRepostViewController"])
            {
                WLRepostViewController *postController = (WLRepostViewController *)navController.topViewController;
                [WLPublishTrack contactPageInput:postController.source main_source:postController.mainSource page_type:postController.page_type];
            }
        }
    }
    
    if (!_maskView)
    {
         __weak typeof(self) weakSelf = self;
        
        _maskView = [[WLMaskView alloc] initWithFrame:CGRectMake(0, kNavBarHeight + 48, kScreenWidth, kScreenHeight - kNavBarHeight - 48)];
        _maskView.closeBlock =  ^(){
            
               [weakSelf.searchField resignFirstResponder];
            
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.maskView.alpha = 0;
                
            } completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf.maskView removeFromSuperview];
                    weakSelf.maskView = nil;
                }
            }];
        };
        
        [self.view addSubview:_maskView];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSLog(@"1=======%lu",textField.text.length);
//    NSLog(@"2======%lu=====%lu",range.location,range.length);
    
    //说明删完了
    if (string.length == 0 && textField.text.length == range.length)
    {
        if (_resultController)
        {
            [_resultController.view removeFromSuperview];
            _resultController = nil;
        }
        return YES;
    }
    
    
    NSMutableString *searchString =  [NSMutableString stringWithString:textField.text];
    
    if (range.length > 0)
    {
        [self filterContentForSearchText:[searchString stringByReplacingCharactersInRange:range withString:string]];
    }
    else
    {
         [self filterContentForSearchText:[NSString stringWithFormat:@"%@%@",searchString,string]];//ok
    }
    
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    _searchString = [NSString stringWithString:searchText];
    //NSLog(@"%@",searchText);
    if (_friendListArray.count > 0)
    {
        [_filteredUserList removeAllObjects];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        if (_friendListArray.count == 2)
        {
            [array addObjectsFromArray:_friendListArray[0]];
            [array addObjectsFromArray:_friendListArray[1]];
        }
        else
        {
            [array addObjectsFromArray:_friendListArray[0]];
        }
        
        
        for (WLContact *contact in array)
        {
            BOOL isRepeat = NO;
            if (searchText && [searchText length] > 0)
            {
                NSRange range = [contact.nickName rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (range.length > 0) // found
                {
                    //便利下看是否有重复
                    for (WLContact *c in _filteredUserList)
                    {
                        if ([c.uid isEqualToString:contact.uid])
                        {
                            isRepeat = YES;
                            break;
                        }
                    }
                    
                    if (isRepeat == NO)
                    {
                        if ([contact.nickName isEqualToString:searchText] == YES)
                        {
                            [_filteredUserList insertObject:contact atIndex:0];
                        }
                        else
                        {
                            [_filteredUserList addObject:contact];
                        }
                    }
                }
            }
        }
    }
    
    __weak typeof(self) weakSelf = self;
    
    if (!_resultController)
    {
        _resultController = [[WLSearchResultDisplayViewController alloc] init];
        _resultController.searchStr = _searchString;
        _resultController.view.frame = CGRectMake(0, kNavBarHeight + 48 , kScreenWidth, kScreenHeight - kNavBarHeight - 48);
        
        _resultController.select = ^(WLContact *contact) {
            
            if ([weakSelf select])
            {
                weakSelf.select(contact);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf dismissViewControllerAnimated:YES
                                             completion:^{
                                                 
                                             }];
            });
        };
        
        [self.view addSubview:_resultController.view];
    }
    else
    {
         _resultController.searchStr = _searchString;
    }
    
     _resultController.friendListArray = _filteredUserList;
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchField resignFirstResponder];
}

-(NSString *)searchStr
{
    return _searchString;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
