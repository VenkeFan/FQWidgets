//
//  WLProfileViewModel.m
//  welike
//
//  Created by fan qi on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLProfileViewModel.h"
#import "WLSettingDataSourceItem.h"
#import "WLDraftManager.h"

@implementation WLProfileViewModel

- (instancetype)init {
    if (self = [super init]) {
        
        NSMutableArray *section1 = [NSMutableArray array];
        WLSettingDataSourceItem *infulencerItem = [[WLSettingDataSourceItem alloc] init];
        infulencerItem.iconResId = @"me_infulencer";
        infulencerItem.title = [AppContext getStringForKey:@"profile_growth_verification" fileName:@"user"];
        infulencerItem.isTail = YES;
        [section1 addObject:infulencerItem];
        
        
        
        WLSettingDataSourceItem *myLikeItem = [[WLSettingDataSourceItem alloc] init];
        myLikeItem.iconResId = @"me_mylike";
        myLikeItem.title = [AppContext getStringForKey:@"mine_invite_friends_text" fileName:@"user"];
        myLikeItem.isTail = YES;
        [section1 addObject:myLikeItem];
        
     
        WLSettingDataSourceItem *shareItem = [[WLSettingDataSourceItem alloc] init];
        shareItem.iconResId = @"profile_transpond";
        shareItem.title = [AppContext getStringForKey:@"mine_rate_us_text" fileName:@"user"];
        shareItem.isTail = YES;
        [section1 addObject:shareItem];
        
        WLSettingDataSourceItem *feedBackItem = [[WLSettingDataSourceItem alloc] init];
        feedBackItem.iconResId = @"me_feedback";
        feedBackItem.title = [AppContext getStringForKey:@"mine_feed_back_text" fileName:@"user"];
        feedBackItem.isTail = YES;
        [section1 addObject:feedBackItem];
    
        
        WLSettingDataSourceItem *settingItem = [[WLSettingDataSourceItem alloc] init];
        settingItem.iconResId = @"profile_setting";
        settingItem.title = [AppContext getStringForKey:@"mine_setting_text" fileName:@"user"];
        settingItem.isTail = YES;
        [section1 addObject:settingItem];
     
         NSMutableArray *section2 = [NSMutableArray array];
        draftItem = [[WLSettingDataSourceItem alloc] init];
        draftItem.iconResId = @"me_draft";
        draftItem.title = [AppContext getStringForKey:@"mine_setting_draft_text" fileName:@"user"];
        draftItem.isTail = NO;
        [section2 addObject:draftItem];
        
        _dataArray = @[section1,section2];
    }
    return self;
}

- (WLAccount *)account {
    return [AppContext getInstance].accountManager.myAccount;
}


-(void)setDraftNum:(NSInteger)draftNum
{
    _draftNum = draftNum;
    
    draftItem.badgeNum = _draftNum;
}

@end
