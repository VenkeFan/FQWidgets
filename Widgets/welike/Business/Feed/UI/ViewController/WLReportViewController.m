//
//  WLReportViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLReportViewController.h"
#import "WLReportSimpleCell.h"
#import "WLReportOtherCell.h"
#import "WLReportRequest.h"
#import "WLAccountManager.h"
#import "WLPostBase.h"

#define kReportTitleHeight         61.f
#define kDesListHeight             38.f

@interface WLReportViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, assign) CGFloat tableHeight;

@end

@implementation WLReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.dataArray = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    
    self.navigationBar.title = [AppContext getStringForKey:@"report" fileName:@"feed"];
    self.view.backgroundColor = kLightBackgroundViewColor;
    
    WLReportSimpleDataSourceItem *item1 = [[WLReportSimpleDataSourceItem alloc] init];
    item1.title = [AppContext getStringForKey:@"report_reason1" fileName:@"feed"];
    item1.selected = NO;
    [self.dataArray addObject:item1];
    
    WLReportSimpleDataSourceItem *item2 = [[WLReportSimpleDataSourceItem alloc] init];
    item2.title = [AppContext getStringForKey:@"report_reason2" fileName:@"feed"];
    item2.selected = NO;
    [self.dataArray addObject:item2];
    
    WLReportSimpleDataSourceItem *item3 = [[WLReportSimpleDataSourceItem alloc] init];
    item3.title = [AppContext getStringForKey:@"report_reason3" fileName:@"feed"];
    item3.selected = NO;
    [self.dataArray addObject:item3];
    
    WLReportSimpleDataSourceItem *item4 = [[WLReportSimpleDataSourceItem alloc] init];
    item4.title = [AppContext getStringForKey:@"report_reason4" fileName:@"feed"];
    item4.selected = NO;
    [self.dataArray addObject:item4];
    
    if (kScreenHeight > 480)
    {
        WLReportOtherDataSourceItem *itemOther = [[WLReportOtherDataSourceItem alloc] init];
        itemOther.title = [AppContext getStringForKey:@"report_reason_others" fileName:@"feed"];
        itemOther.selected = NO;
        [self.dataArray addObject:itemOther];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *titleBack = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, self.view.width, kReportTitleHeight)];
    titleBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleBack];
    
    NSString *nickName = [NSString stringWithFormat:@"@%@", self.post.nickName];
    NSString *title = [NSString stringWithFormat:[AppContext getStringForKey:@"report_post" fileName:@"feed"], nickName];
    NSMutableAttributedString *titleRich = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange r = [title rangeOfString:nickName];
    [titleRich addAttribute:NSForegroundColorAttributeName value:kClickableTextColor range:r];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, kNavBarHeight, self.view.width - kLargeBtnXMargin, kReportTitleHeight)];
    titleLabel.font = [UIFont systemFontOfSize:kNoteFontSize];
    titleLabel.textColor = kNameFontColor;
    titleLabel.attributedText = titleRich;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    UILabel *desListLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, titleBack.bottom, self.view.width - kLargeBtnXMargin, kDesListHeight)];
    desListLabel.font = [UIFont systemFontOfSize:kErrorNoteFontSize];
    desListLabel.textColor = kBodyFontColor;
    desListLabel.text = [AppContext getStringForKey:@"report_select_reason" fileName:@"feed"];
    [self.view addSubview:desListLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, desListLabel.bottom, self.view.width - kLargeBtnXMargin * 2, 1.f)];
    line.backgroundColor = kSeparateLineColor;
    [self.view addSubview:line];
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin - kSafeAreaBottomY, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.btn setTitle:[AppContext getStringForKey:@"common_confirm" fileName:@"common"] forState:UIControlStateNormal];
    [self.btn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.btn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.btn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateDisabled];
    [self.btn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.btn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.btn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
    [self.btn setEnabled:NO];
    [self.btn.layer setMasksToBounds:YES];
    [self.btn.layer setCornerRadius:kLargeBtnRadius];
    [self.btn addTarget:self action:@selector(onDone) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableHeight = self.view.height - kNavBarHeight - titleBack.height - desListLabel.height - 1.f - self.btn.height - kLargeBtnYMargin - kSafeAreaBottomY;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, line.bottom, self.view.width, self.tableHeight) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kLightBackgroundViewColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.btn];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLReportSimpleDataSourceItem class]])
        {
            WLReportSimpleCell *simpleCell = [tableView dequeueReusableCellWithIdentifier:WLReportSimpleCellIdentifier];
            if (simpleCell == nil)
            {
                simpleCell = [[WLReportSimpleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLReportSimpleCellIdentifier];
                [simpleCell setDataSourceItem:item];
            }
            else
            {
                [simpleCell setDataSourceItem:item];
            }
            cell = simpleCell;
        }
        else if ([item isKindOfClass:[WLReportOtherDataSourceItem class]])
        {
            WLReportOtherCell *otherCell = [tableView dequeueReusableCellWithIdentifier:WLReportOtherCellIdentifier];
            if (otherCell == nil)
            {
                otherCell = [[WLReportOtherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLReportOtherCellIdentifier];
                [otherCell setDataSourceItem:item];
            }
            else
            {
                [otherCell setDataSourceItem:item];
            }
            cell = otherCell;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLReportSimpleDataSourceItem class]])
        {
            return ((WLReportSimpleDataSourceItem *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLReportOtherDataSourceItem class]])
        {
            return ((WLReportOtherDataSourceItem *)item).cellHeight;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        [self clearAllSelected];
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLReportSimpleDataSourceItem class]])
        {
            ((WLReportSimpleDataSourceItem *)item).selected = YES;
        }
        else if ([item isKindOfClass:[WLReportOtherDataSourceItem class]])
        {
            ((WLReportOtherDataSourceItem *)item).selected = YES;
        }
        [self.tableView reloadData];
        
        [self.btn setEnabled:YES];
    }
}

#pragma mark private
- (void)onDone
{
    WLReportRequest *request = [[WLReportRequest alloc] initReportRequestWithUid:[[AppContext getInstance].accountManager myAccount].uid];
    for (NSInteger i = 0; i < [self.dataArray count]; i++)
    {
        id item = [self.dataArray objectAtIndex:i];
        if ([item isKindOfClass:[WLReportSimpleDataSourceItem class]])
        {
            WLReportSimpleDataSourceItem *simple = (WLReportSimpleDataSourceItem *)item;
            if (simple.selected == YES)
            {
                [self showLoading];
                __weak typeof(self) weakSelf = self;
                [request reportWithPost:self.post reason:simple.title successed:^{
                    [weakSelf hideLoading];
                    [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"report_completed" fileName:@"common"]];
                    [[AppContext rootViewController] popViewControllerAnimated:YES];
                } error:^(NSInteger errorCode) {
                    [weakSelf hideLoading];
                    [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"report_completed" fileName:@"common"]];
                }];
                break;
            }
        }
        else if ([item isKindOfClass:[WLReportOtherDataSourceItem class]])
        {
            WLReportOtherDataSourceItem *other = (WLReportOtherDataSourceItem *)item;
            if (other.selected == YES)
            {
                [self showLoading];
                __weak typeof(self) weakSelf = self;
                NSString *reason = nil;
                if ([other.feedback length] > 0)
                {
                    reason = other.feedback;
                }
                else
                {
                    reason = other.title;
                }
                [request reportWithPost:self.post reason:reason successed:^{
                    [weakSelf hideLoading];
                    [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"report_completed" fileName:@"common"]];
                    [[AppContext rootViewController] popViewControllerAnimated:YES];
                } error:^(NSInteger errorCode) {
                    [weakSelf hideLoading];
                    [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"report_completed" fileName:@"common"]];
                }];
            }
        }
    }
}

- (void)onKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.btn.bottom = self.view.height - height - kLargeBtnYMargin;

    self.tableView.frame = CGRectMake(0, self.tableView.top, self.tableView.width, self.btn.top - kLargeBtnYMargin - self.tableView.top);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.dataArray count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
    self.btn.bottom = self.view.bottom - kLargeBtnYMargin - kSafeAreaBottomY;
    self.tableView.frame = CGRectMake(0, self.tableView.top, self.tableView.width, self.tableHeight);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)clearAllSelected
{
    for (NSInteger i = 0; i < [self.dataArray count]; i++)
    {
        id item = [self.dataArray objectAtIndex:i];
        if ([item isKindOfClass:[WLReportSimpleDataSourceItem class]])
        {
            ((WLReportSimpleDataSourceItem *)item).selected = NO;
        }
        else if ([item isKindOfClass:[WLReportOtherDataSourceItem class]])
        {
            ((WLReportOtherDataSourceItem *)item).selected = NO;
        }
    }
}

@end
