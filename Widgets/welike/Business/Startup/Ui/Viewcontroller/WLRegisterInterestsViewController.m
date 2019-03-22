//
//  WLRegisterInterestsViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterInterestsViewController.h"
#import "WLInterestsSuggester.h"
#import "WLStartHandler.h"
#import "UIScrollView+FQEmptyData.h"
#import "WLInterestLabelSelectView.h"

#define kRegisterInterestsMainTitleTopMargin           63.f
#define kRegisterInterestsMainTitleHeight              26.f
#define kRegisterInterestsSubTitleTopMargin            8.f
#define kRegisterInterestsSubTitleHeight               17.f
#define kRegisterInterestsTableViewTop                 19.f
#define kInterestLabelGroupLeftPading                  12.0

@interface WLRegisterInterestsViewController () <WLStartHandlerDelegate, WLInterestsSuggesterDelegate, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource,WLInterestLabelSelectViewDelegate>

@property (nonatomic,strong) WLInterestLabelSelectView *selectView;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) WLInterestsSuggester *interestsSuggester;
@property (nonatomic, strong) NSArray<WLInterestLabelMenuModel *> *dataArray;

@end

@implementation WLRegisterInterestsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.interestsSuggester = [[WLInterestsSuggester alloc] init];
        self.interestsSuggester.delegate = self;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.interestsSuggester refresh];
}

- (void)layout
{
    [self.view removeAllSubviews];
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, kRegisterInterestsMainTitleTopMargin, self.view.width - kLargeBtnXMargin * 2, kRegisterInterestsMainTitleHeight)];
    mainTitle.backgroundColor = [UIColor clearColor];
    mainTitle.textColor = kWeightTitleFontColor;
    mainTitle.textAlignment = NSTextAlignmentLeft;
    mainTitle.text = [AppContext getStringForKey:@"regist_suggest_interests_title" fileName:@"register"];
    mainTitle.font = [UIFont systemFontOfSize:kNameFontSize];
    [self.view addSubview:mainTitle];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, mainTitle.bottom + kRegisterInterestsSubTitleTopMargin, self.view.width - kLargeBtnXMargin * 2, kRegisterInterestsSubTitleHeight)];
    subTitle.backgroundColor = [UIColor clearColor];
    subTitle.textColor = kLightLightFontColor;
    subTitle.textAlignment = NSTextAlignmentLeft;
    subTitle.font = [UIFont systemFontOfSize:kLinkFontSize];
    subTitle.text = [AppContext getStringForKey:@"regist_suggest_interests_sub_title" fileName:@"register"];
    [self.view addSubview:subTitle];
    
    NSString *nextTitle = [AppContext getStringForKey:@"regist_next_btn" fileName:@"register"];
    if (self.nextBtn == nil)
    {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.nextBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin - kSafeAreaBottomY, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.nextBtn setTitle:nextTitle forState:UIControlStateNormal];
    [self.nextBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.nextBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
    [self.nextBtn setEnabled:NO];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.nextBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];
    
    CGFloat tableHeight = self.view.height - (subTitle.bottom + kRegisterInterestsTableViewTop) - kSafeAreaBottomY;// - self.nextBtn.height - kLargetBtnYMargin * 2 - kSafeAreaBottomY;
    self.selectView = [[WLInterestLabelSelectView alloc] initWithFrame:CGRectMake(0, subTitle.bottom + kRegisterInterestsTableViewTop, self.view.width, tableHeight)];
    self.selectView.contentInset = UIEdgeInsetsMake(0, 0, self.nextBtn.height + kLargeBtnYMargin * 2, 0);
    self.selectView.selectDelegate = self;
    [self.view addSubview:self.selectView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.nextBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppContext getInstance].startHandler registerWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppContext getInstance].startHandler unregister:self];
}

#pragma mark WLInterestsSuggesterDelegate methods
- (void)onRefreshInetrestSuggestions:(NSArray *)interests referrerInfo:(WLReferrerInfo *)referrerInfo errCode:(NSInteger)errCode
{
    if (errCode == ERROR_SUCCESS)
    {
        self.dataArray = interests;
        [self.nextBtn setTitle: [AppContext getStringForKey:@"regist_next_btn" fileName:@"register"] forState:UIControlStateNormal];
        if ([self selectedCount] >= 2)
        {
            [self.nextBtn setEnabled:YES];
        }
        else
        {
            [self.nextBtn setEnabled:NO];
        }
    }
    else
    {
        [self.nextBtn setTitle:[AppContext getStringForKey:@"common_reload_text" fileName:@"common"] forState:UIControlStateNormal];
        [self.nextBtn setEnabled:YES];
    }
    [self.selectView bindModels:self.dataArray];
}

#pragma mark UIScrollViewEmptyDelegate methods
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    if (self.selectView == scrollView)
    {
        [self.interestsSuggester refresh];
    }
}

#pragma mark UIScrollViewEmptyDataSource methods
- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.selectView == scrollView)
    {
        return [AppContext getStringForKey:@"load_error" fileName:@"common"];
    }
    return @"";
}

#pragma mark WLStartHandlerDelegate methods
- (void)goProcess:(WELIKE_STARTUP_STATE)state
{
    [self hideLoading];
    [[AppContext getInstance].startHandler runNext:state];
}

- (void)goFailed:(NSInteger)errcode
{
    [self hideLoading];
    [self showToastWithNetworkErr:errcode];
}

#pragma mark private methods
- (void)onNext
{
    if ([self.dataArray count] == 0)
    {
        [self.interestsSuggester refresh];
    }
    else
    {
        [self showLoading];
        NSMutableArray *selectedList = [NSMutableArray arrayWithCapacity:[self.dataArray count]];
        for (NSInteger i = 0; i < [self.dataArray count]; i++)
        {
            WLInterestLabelMenuModel *item = [self.dataArray objectAtIndex:i];
            if (item.isSelected == YES)
            {
                NSDictionary *interest = [NSDictionary dictionaryWithObjectsAndKeys:item.interestId, @"id", nil];
                [selectedList addObject:interest];
            }
            for (NSInteger j = 0; j < item.labelModels.count; j++) {
                WLInterestLabelModel *labelItem = item.labelModels[j];
                if (labelItem.isSelected) {
                    NSDictionary *interest = [NSDictionary dictionaryWithObjectsAndKeys:labelItem.interestId, @"id", nil];
                    [selectedList addObject:interest];
                }
            }
        }
        [AppContext getInstance].startHandler.interests = selectedList;
        [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_REGISTER_TRY_INTERESTS];
    }
}

- (NSInteger)selectedCount
{
    if ([self.dataArray count] > 0)
    {
        NSInteger count = 0;
        for (NSInteger i = 0; i < [self.dataArray count]; i++)
        {
            WLInterestLabelMenuModel *item = [self.dataArray objectAtIndex:i];
            if (item.isSelected == YES)
            {
                count++;
            }
            count += [item selectCount];
        }
        return count;
    }
    return 0;
}

#pragma mark - WLInterestLabelSelectViewDelegate

- (void)didClickInterestLabelSelectView:(WLInterestLabelSelectView *)selectView
{
    if ([self selectedCount] >= 2)
    {
        [self.nextBtn setEnabled:YES];
    }
    else
    {
        [self.nextBtn setEnabled:NO];
    }
}

@end
