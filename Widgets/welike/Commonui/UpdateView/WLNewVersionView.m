//
//  WLNewVersionView.m
//  welike
//
//  Created by gyb on 2018/10/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNewVersionView.h"
#import "WLNewVersionInfo.h"


@implementation WLNewVersionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI
{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bg.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self addSubview:bg];
    
    
    UIImage *dialogBgImage = [AppContext getImageForKey:@"update_bg"];
    dialogBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dialogBgImage.size.width, dialogBgImage.size.height)];
    dialogBg.image = [dialogBgImage stretchableImageWithLeftCapWidth:0 topCapHeight:150];
    dialogBg.userInteractionEnabled = YES;
    [self addSubview:dialogBg];
    dialogBg.center = self.center;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 45, 140, 28)];
    titleLabel.font = kRegularFont(20);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = [AppContext getStringForKey:@"mine_check_the_update_title" fileName:@"user"];
    [dialogBg addSubview:titleLabel];
    
    versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, titleLabel.bottom, 140, 22)];
    versionLabel.font = kRegularFont(16);
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.text = [AppContext getStringForKey:@"mine_check_the_update_version" fileName:@"user"];
    [dialogBg addSubview:versionLabel];
    
    
    infoTextView = [[UITextView alloc] initWithFrame:CGRectMake(18, 155, 244, 0)];
    infoTextView.font = kRegularFont(14);
    infoTextView.textColor = kDialogFontColor;
    infoTextView.editable = NO;
    [dialogBg addSubview:infoTextView];
    
    UIImage *cancelImage = [AppContext getImageForKey:@"update_cancel"];
    UIImage *confirmImage = [AppContext getImageForKey:@"update_confirm"];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake( 16, dialogBg.height - 16 - 40, 116, 40);
    [cancelBtn setTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = kBoldFont(16);
    [cancelBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:cancelImage forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [dialogBg addSubview:cancelBtn];
    
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(cancelBtn.right + 15, cancelBtn.top, 116, 40);
    [confirmBtn setTitle:[AppContext getStringForKey:@"common_confirm" fileName:@"common"] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[confirmImage stretchableImageWithLeftCapWidth:30 topCapHeight:0] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = kBoldFont(16);
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [dialogBg addSubview:confirmBtn];
}


-(void)cancelBtnPressed
{
    //记录点击
    if (_versionInfo.updateType == UpdateWithChoice)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:_versionInfo.version];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [self removeFromSuperview];
}

-(void)confirmBtnPressed
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStroeUrl]];
   
    if (_versionInfo.updateType == UpdateWithChoice)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:_versionInfo.version];
        [[NSUserDefaults standardUserDefaults] synchronize];
         [self removeFromSuperview];
    }
}


-(void)setVersionInfo:(WLNewVersionInfo *)versionInfo {
    _versionInfo = versionInfo;
    
    CGFloat height = [_versionInfo.updateContent boundingRectWithSize:CGSizeMake(infoTextView.width - infoTextView.textContainer.lineFragmentPadding * 2, 170) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kRegularFont(14)} context:nil].size.height;
    
    if (height < 35)
    {
        infoTextView.height = 35;
    }
    else
    {
        infoTextView.height = height;
        infoTextView.contentSize = CGSizeMake(infoTextView.contentSize.width, height);
    }
    
    infoTextView.text = _versionInfo.updateContent;
    
    dialogBg.height = 150 + infoTextView.height + 20 + 40 + 16;
    dialogBg.center = self.center;
    
    
    //检测几个按钮,进行布局
    if (_versionInfo.updateType == ForceUpdate) //强制升级
    {
        cancelBtn.hidden = YES;
        cancelBtn.frame =  CGRectMake(16, dialogBg.height - 16 - 40, 116, 40);
        confirmBtn.frame = CGRectMake(cancelBtn.left, cancelBtn.top, dialogBg.width - cancelBtn.left *2, 40);
    }
    else//只提示
    {
        cancelBtn.hidden = NO;
        cancelBtn.frame =  CGRectMake(16, dialogBg.height - 16 - 40, 116, 40);
        confirmBtn.frame = CGRectMake(cancelBtn.right + 15, cancelBtn.top, 116, 40);
    }
    
    
    versionLabel.text = [NSString stringWithFormat:@"%@%@",[AppContext getStringForKey:@"mine_check_the_update_version" fileName:@"user"],versionInfo.version];
}


@end
