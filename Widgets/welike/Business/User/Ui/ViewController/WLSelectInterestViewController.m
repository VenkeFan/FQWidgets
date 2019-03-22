//
//  WLSelectInterestViewController.m
//  welike
//
//  Created by gyb on 2019/1/14.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLSelectInterestViewController.h"
#import "WLWatchWithoutLoginRequestManager.h"
#import "WLVerticalItem.h"


@interface WLSelectInterestViewController ()
{
    NSMutableArray *btns;
}


@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *manager;
@property (nonatomic, strong, readwrite) NSMutableArray<WLVerticalItem *> *dataArray;

@end


@implementation WLSelectInterestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.title = [AppContext getStringForKey:@"Select_interest" fileName:@"user"];
    self.view.backgroundColor = [UIColor whiteColor];
    
   
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 56, 24);
    saveBtn.showsTouchWhenHighlighted = YES;
    [saveBtn setTitleColor:send_text_color_enable forState:UIControlStateNormal];
    [saveBtn setTitle:[AppContext getStringForKey:@"mine_user_host_personal_edit_name_save" fileName:@"user"] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = kBoldFont(14);
    saveBtn.backgroundColor = kMainColor;
    saveBtn.layer.cornerRadius = 3;
    [saveBtn addTarget:self action:@selector(saveBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationBar.rightBtnArrayWithGap = [NSArray arrayWithObjects:saveBtn,nil];
    
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    btns = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    [self.manager listAllVertical:^(NSArray *items, NSInteger errCode) {
      
        if (errCode == ERROR_SUCCESS) {
            [self.dataArray addObjectsFromArray:items];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //显示所有
                [self arrangeAllInterest];
            });
        }
        else
        {
            //显示错误刷新
            
        }
    }];
    
}

#pragma mark - Getter

- (WLWatchWithoutLoginRequestManager *)manager {
    if (!_manager) {
        _manager = [[WLWatchWithoutLoginRequestManager alloc] init];
    }
    return _manager;
}


-(void)arrangeAllInterest
{
    for (int i = 0; i < _dataArray.count; i++)
    {
        WLVerticalItem *industry = _dataArray[i];
        
        if (![industry isKindOfClass:[WLVerticalItem class]]) {
            continue;
        }
        
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = 10 + i;
        [btn setTitle:industry.name forState:UIControlStateNormal];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateSelected];
        btn.titleLabel.font = kBoldFont(kLinkFontSize);
        btn.titleLabel.numberOfLines = 1;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.layer.borderColor = kMainColor.CGColor;
        btn.layer.borderWidth = 1.0;
        btn.layer.cornerRadius = 16;
        btn.clipsToBounds = YES;
        [btn addTarget:self action:@selector(itemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat width = (kScreenWidth - 25)/2.0;
        
        if (i%2 == 0)
        {
            btn.frame = CGRectMake(8, kNavBarHeight + 15 + (i/2)*(32 + 10), width, 32);
        }
        else
        {
            btn.frame = CGRectMake(8 + width + 9, kNavBarHeight + 15 + (i/2)*(32 + 10), width, 32);
        }
        
        [self.view addSubview:btn];
        
        [btns addObject:btn];
        
        
        //拿到保存的数据
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        
        NSArray *intrests = account.interests;
 
        for (int i = 0; i < intrests.count; i++)
        {
            NSDictionary *dic = intrests[i];
            if ([[dic stringForKey:@"id"] isEqual:industry.verticalId])
            {
                btn.selected = YES;
            }
        }
    }
}

-(void)itemBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
   // NSInteger tag = btn.tag;
    
    btn.selected = !btn.selected;
}

-(void)saveBtnPressed
{
    NSMutableArray *interests = [[NSMutableArray alloc] initWithCapacity:0];
    
    //拿到数据
    for (int i = 0; i < btns.count; i++) {
        
        UIButton *btn = btns[i];
        
        if (btn.selected == YES)
        {
            NSInteger tag = btn.tag - 10;
            
            WLVerticalItem *industry = _dataArray[tag];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:industry.icon,@"icon",
                                 industry.verticalId,@"id",
                                 [NSNumber numberWithInteger:industry.labelOrder],@"labelOrder",
                                 industry.name,@"name",nil];
            
            
            if (industry.verticalId.length > 0) {
                [interests addObject:dic];
            }
        }
    }
    
    if (interests.count == 0)
    {
        [self showToast:[AppContext getStringForKey:@"user_interest_info_title" fileName:@"user"]];
        return;
    }
    
    
    
    [[AppContext getInstance].accountManager syncAccountInterests:interests successed:^{
      
        [self.navigationController popViewControllerAnimated:YES];
        
    } error:^(NSInteger errCode) {
        
        //  NSLog(@"保存失败");
    }];
}




@end
