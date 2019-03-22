//
//  WLDraftViewController.m
//  welike
//
//  Created by gyb on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDraftViewController.h"
#import "WLPostViewController.h"
#import "WLCommentPostViewController.h"
#import "WLRepostViewController.h"
#import "WLDraftCell.h"
#import "WLDraft.h"
#import "WLHandledFeedModel.h"
#import "WLDraftInfo.h"
#import "WLFeedTableView.h"
#import "WLDraftManager.h"
#import "CKAlertViewController.h"

@interface WLDraftViewController ()<WLNavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,WLNavigationBarDelegate,UIScrollViewEmptyDelegate,UIScrollViewEmptyDataSource,UIAlertViewDelegate>

@property (strong,nonatomic) WLFeedTableView *draftTableView;
@property (strong,nonatomic) NSMutableArray *draftArray;


@end

@implementation WLDraftViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationBar.title = [AppContext getStringForKey:@"publish_draft_title" fileName:@"publish"];
    
    [self.navigationBar setRightBtnImageName:@"draft_clear"];
    self.navigationBar.rightBtn.hidden = NO;

    _draftArray = [[NSMutableArray alloc] initWithCapacity:0];

    _draftTableView = [[WLFeedTableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth ,kScreenHeight - kNavBarHeight - kSafeAreaBottomY) style:UITableViewStylePlain];
//    _draftTableView.backgroundColor = [UIColor whiteColor];
    _draftTableView.delegate = self;
    _draftTableView.dataSource = self;
    _draftTableView.emptyDelegate = self;
    _draftTableView.emptyDataSource = self;
    _draftTableView.disableHeaderRefresh = YES;
    _draftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_draftTableView];

    _draftTableView.estimatedRowHeight = 0;
    _draftTableView.estimatedSectionHeaderHeight = 0;
    _draftTableView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)){
        _draftTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [self readDraft];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDraft) name:WLNotificationUpdateDraft object:nil];
}

-(void)readDraft
{
    //读取数据数组
    __weak typeof(self) weakSelf = self;
    
    [[AppContext getInstance].draftManager listAll:^(NSArray *draftList) {

         [weakSelf.draftArray removeAllObjects];
        
        //根据类型转换为包含原文和不包含原文的富文本数据并赋值
        for (int i = 0; i < draftList.count; i++)
        {
            WLDraftInfo *draftInfo = [[WLDraftInfo alloc] init];

            draftInfo.draftBase = draftList[i];

            [weakSelf.draftArray addObject:draftInfo];
        }
       

        dispatch_async(dispatch_get_main_queue(), ^{

           weakSelf.draftTableView.emptyType = WLScrollEmptyType_Empty_Data;
             [weakSelf.draftTableView reloadData];
            [weakSelf.draftTableView reloadEmptyData];
        });
    }];
}

#pragma mark Notification
-(void)refreshDraft
{
    [self readDraft];
}

#pragma mark UITableView delegate

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
      return _draftArray.count;
}


- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return [_draftArray[indexPath.row] cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        WLDraftInfo *draftInfo = [_draftArray objectAtIndex:indexPath.row];
        
        [[AppContext getInstance].draftManager deleteDraftWithId:draftInfo.draftBase.draftId];
        
        [_draftArray removeObjectAtIndex:indexPath.row];
        
        if (_draftArray.count == 0)
        {
            //_draftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.draftTableView.emptyType = WLScrollEmptyType_Empty_Data;
            [self.draftTableView reloadEmptyData];
        }
        
        [self.draftTableView reloadData];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RootCellIdentifier = @"DraftCell";
    WLDraftCell *cell = (WLDraftCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLDraftCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       // cell.contentView.backgroundColor = searchBarBg;
    }
    
    cell.delegate = self;
    cell.draftInfo = _draftArray[indexPath.row];
    [cell drawCell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLDraftInfo *info = _draftArray[indexPath.row];
    
   // WLDraftBase *draftBase = info.draftBase;
    
    if (info.draftBase.type == WELIKE_DRAFT_TYPE_POST)
    {
        WLPostViewController *postViewController = [[WLPostViewController alloc] init];
        postViewController.type = info.draftBase.type;
        postViewController.isReadFromDraft = YES;
        postViewController.draftBase = info.draftBase;
        [self.navigationController pushViewController:postViewController animated:YES];
    }
    
    if (info.draftBase.type == WELIKE_DRAFT_TYPE_FORWARD_POST ||
        info.draftBase.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
    {
        WLRepostViewController *postViewController = [[WLRepostViewController alloc] init];
        postViewController.type = info.draftBase.type;
        postViewController.isReadFromDraft = YES;
        postViewController.draftBase = info.draftBase;
        [self.navigationController pushViewController:postViewController animated:YES];
        
        
    }
    if (info.draftBase.type == WELIKE_DRAFT_TYPE_COMMENT ||
        info.draftBase.type == WELIKE_DRAFT_TYPE_REPLY   ||
        info.draftBase.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
    {
        WLCommentPostViewController *postViewController = [[WLCommentPostViewController alloc] init];
        postViewController.type = info.draftBase.type;
        postViewController.isReadFromDraft = YES;
        postViewController.draftBase = info.draftBase;
        [self.navigationController pushViewController:postViewController animated:YES];
    }
    
}

#pragma mark - TYTextViewDelegate
-(void)resendDidTaped:(WLDraftInfo *)draftInfo
{
    NSInteger indexNum;
    for (int i = 0; i < _draftArray.count; i++)
    {
        WLDraftInfo *info = _draftArray[i];
        
        if ([draftInfo.draftBase.draftId isEqualToString:info.draftBase.draftId])
        {
            indexNum = i;
            
            [_draftArray removeObjectAtIndex:indexNum];
            [self.draftTableView reloadData];
            
            if (_draftArray.count == 0)
            {
//                 _draftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                self.draftTableView.emptyType = WLScrollEmptyType_Empty_Data;
                  [self.draftTableView reloadEmptyData];
            }
            
            break;
        }
    }
}

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    if (scrollView.emptyType == WLScrollEmptyType_Empty_Data)
    {
        [self readDraft];
    }
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (scrollView.emptyType == WLScrollEmptyType_Empty_Data)
    {
        return [AppContext getStringForKey:@"draft_empty_text" fileName:@"publish"];
    }
    else
    {
        return nil;
    }
}


#pragma mark WLNavigationBarDelegate
-(void)navigationBarRightBtnDidClicked
{
      __weak typeof(self) weakSelf = self;

    NSString *messageStr = [AppContext getStringForKey:@"clear_draft_title" fileName:@"publish"];

    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:messageStr];
    [messageString addAttribute:NSFontAttributeName value:kRegularFont(16) range:NSMakeRange(0, messageStr.length)];

    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:nil message:messageString];

    CKAlertAction *cancel = [CKAlertAction actionWithTitle:[AppContext getStringForKey:@"editor_discard_cancel" fileName:@"publish"]       handler:^(CKAlertAction *action) {
        [alertVC.view removeFromSuperview];
    }];

    CKAlertAction *sure = [CKAlertAction actionWithDeepColorTitle:[AppContext getStringForKey:@"common_ok" fileName:@"common"]
                                                 handler:^(CKAlertAction *action) {
                                                     [[AppContext getInstance].draftManager clearAll];
                                                     [weakSelf.draftArray removeAllObjects];
                                                     self.draftTableView.emptyType = WLScrollEmptyType_Empty_Data;
                                                     [self.draftTableView reloadData];
                                                     [self.draftTableView reloadEmptyData];
                                                     [alertVC.view removeFromSuperview];
    }];

    [alertVC addAction:cancel];
    [alertVC addAction:sure];

    [alertVC show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
