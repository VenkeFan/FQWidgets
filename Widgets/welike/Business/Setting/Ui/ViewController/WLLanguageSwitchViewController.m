//
//  WLLanguageSwitchViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLanguageSwitchViewController.h"
#import "WLLanguageSelectCell.h"
#import "WLEmptySectionCell.h"
#import "RDLocalizationManager.h"
#import "WLTrackerLanguage.h"

@interface WLLanguageSwitchViewController ()

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UIButton *saveBtn;

@end

@implementation WLLanguageSwitchViewController

- (void)loadView
{
    [super loadView];
    self.dataList = [NSMutableArray array];
    self.navigationBar.title = [AppContext getStringForKey:@"mine_setting_language_text" fileName:@"user"];
    
    WLLanguageSelectDataSourceItem *eng = [[WLLanguageSelectDataSourceItem alloc] init];
    eng.display = [AppContext getStringForKey:@"regist_choose_language_english" fileName:@"register"];
    eng.language = LANGUAGE_TYPE_ENG;
    if ([[[RDLocalizationManager getInstance] getCurrentLanguage] isEqualToString:LANGUAGE_TYPE_ENG] == YES)
    {
        eng.selected = YES;
    }
    else
    {
        eng.selected = NO;
    }
    eng.isTail = YES;
    [self.dataList addObject:eng];
    
    WLLanguageSelectDataSourceItem *hindi = [[WLLanguageSelectDataSourceItem alloc] init];
    hindi.display = [AppContext getStringForKey:@"regist_choose_language_hindi" fileName:@"register"];
    hindi.language = LANGUAGE_TYPE_HINDI;
    if ([[[RDLocalizationManager getInstance] getCurrentLanguage] isEqualToString:LANGUAGE_TYPE_HINDI] == YES)
    {
        hindi.selected = YES;
    }
    else
    {
        hindi.selected = NO;
    }
    hindi.isTail = NO;
    [self.dataList addObject:hindi];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0, kTabBarHeight + kSystemStatusBarHeight, CGRectGetWidth(self.view.bounds), self.view.height - (kTabBarHeight + kSystemStatusBarHeight) - kLargeBtnHeight - kLargeBtnYMargin - kSafeAreaBottomY);
    
    NSString *saveTitle = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_save" fileName:@"user"];
    if (self.saveBtn == nil)
    {
        self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.saveBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin - kSafeAreaBottomY, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.saveBtn setTitle:saveTitle forState:UIControlStateNormal];
    [self.saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.saveBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.saveBtn.layer setMasksToBounds:YES];
    [self.saveBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.saveBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate & UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLLanguageSelectDataSourceItem class]])
        {
            WLLanguageSelectCell *languageCell = [tableView dequeueReusableCellWithIdentifier:WLLanguageSelectCellIdentifier];
            if (languageCell == nil)
            {
                languageCell = [[WLLanguageSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLLanguageSelectCellIdentifier];
                [languageCell setDataSourceItem:item];
            }
            else
            {
                [languageCell setDataSourceItem:item];
            }
            cell = languageCell;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLLanguageSelectDataSourceItem class]])
        {
            return ((WLLanguageSelectDataSourceItem *)item).cellHeight;
        }
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLLanguageSelectDataSourceItem class]])
        {
            [self unselectInArr];
            ((WLLanguageSelectDataSourceItem *)item).selected = YES;
            [tableView reloadData];
        }
    }
}

#pragma mark private
- (void)onSave
{
    NSString *language = [self selectedLanguage];
    if ([language isEqualToString:[[RDLocalizationManager getInstance] getCurrentLanguage]] == NO)
    {
        [[RDLocalizationManager getInstance] switchLanguage:language];
        
        [WLTrackerLanguage appendTrackerWithLang:language source:WLTrackerLanguageSource_Setting];
    }
    else
    {
        [[AppContext rootViewController] popViewControllerAnimated:YES];
    }
}

- (void)unselectInArr
{
    for (NSInteger i = 0; i < [self.dataList count] > 0; i++)
    {
        id item = [self.dataList objectAtIndex:i];
        if ([item isKindOfClass:[WLLanguageSelectDataSourceItem class]])
        {
            ((WLLanguageSelectDataSourceItem *)item).selected = NO;
        }
    }
}

- (NSString *)selectedLanguage
{
    for (NSInteger i = 0; i < [self.dataList count] > 0; i++)
    {
        id item = [self.dataList objectAtIndex:i];
        if ([item isKindOfClass:[WLLanguageSelectDataSourceItem class]])
        {
            if (((WLLanguageSelectDataSourceItem *)item).selected == YES)
            {
                return ((WLLanguageSelectDataSourceItem *)item).language;
            }
        }
    }
    return nil;
}

@end
