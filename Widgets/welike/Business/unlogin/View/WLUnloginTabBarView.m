//
//  WLUnloginTabBarView.m
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnloginTabBarView.h"
#import "FQTabBarView.h"


#define MarginX             (20)

@implementation WLUnloginTabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
         [self layoutUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)resumeAnimationPlay
{
    [animationView play];
}


- (void)layoutUI
{
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowPath = CGPathCreateWithRect(self.bounds, NULL);
    
    
    FQTabBarItem *publishView = ({
        FQTabBarItem *view = [[FQTabBarItem alloc] initWithFrame:CGRectMake(0, 0, kSingleTabBarHeight, kSingleTabBarHeight)];
        view.type = FQTabBarItemType_Present;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barItemTapped:)];
        [view addGestureRecognizer:tap];
        
        UIImage *loginImage = [AppContext getImageForKey:@"tab_unlogin_login"];
        
        UIImageView *loginView = [[UIImageView alloc] initWithFrame:CGRectMake((view.bounds.size.width - loginImage.size.width)/2.0, (49 - loginImage.size.height)/2.0 + 2, loginImage.size.width, loginImage.size.height)];
        loginView.image = loginImage;
        [view addSubview:loginView];
    
        
        animationView = [[LOTAnimationView alloc] initWithFrame:CGRectMake(-2, -5, loginView.width+4, loginView.height+6)];
        animationView.contentMode = UIViewContentModeScaleAspectFill;
        [animationView setAnimationNamed:@"loginBtnAnimation"];
        [loginView addSubview:animationView];
        animationView.loopAnimation = YES;
        [animationView play];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 0 -3, loginView.width, loginView.height)];
        titleLabel.text = [AppContext getStringForKey:@"regist_phone_num_title" fileName:@"register"];
        titleLabel.font = kBoldFont(14);
        titleLabel.textColor = [UIColor whiteColor];

        titleLabel.textAlignment = NSTextAlignmentCenter;
        [loginView addSubview:titleLabel];
        
        
        
        view;
    });
    self.publishView = publishView;
    [self addSubview:publishView];
    [publishView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-kSafeAreaBottomY * 0.5);
        make.size.mas_equalTo(kSingleTabBarHeight);
    }];
    
    FQTabBarItem *homeBtn = [self createBtnWithTitle:[AppContext getStringForKey:@"main_tab_home" fileName:@"feed"]
                                           normalImg:@"main_home_normal"
                                         selectedImg:@"main_home_selected"];
    homeBtn.selected = YES;
    [homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.publishView).offset(-60-kSingleTabBarHeight);
        make.centerY.mas_equalTo(self).offset(-kSafeAreaBottomY * 0.5);
        make.size.mas_equalTo(kSingleTabBarHeight);
    }];
    
    FQTabBarItem *disBtn = [self createBtnWithTitle:[AppContext getStringForKey:@"main_tab_discover" fileName:@"feed"]
                                          normalImg:@"main_discovery_normal"
                                        selectedImg:@"main_discovery_selected"];
    [disBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.publishView).mas_offset(60 + kSingleTabBarHeight);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    self.items = @[homeBtn, disBtn];
}

#pragma mark - Private

- (FQTabBarItem *)createBtnWithTitle:(NSString *)title normalImg:(NSString *)normalImg selectedImg:(NSString *)selectedImg {
    FQTabBarItem *barItem = [[FQTabBarItem alloc] initWithType:FQTabBarItemType_Exclusive];
    barItem.title = title;
    barItem.imgName = normalImg;
    barItem.selectedImgName = selectedImg;
    barItem.selected = NO;
    [self addSubview:barItem];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barItemTapped:)];
    [barItem addGestureRecognizer:tap];
    
    return barItem;
}

#pragma mark - Event

- (void)barItemTapped:(UIGestureRecognizer *)gesture {
    FQTabBarItem *barItem = (FQTabBarItem *)gesture.view;
    if (!barItem) {
        return;
    }
    
    if (barItem.type == FQTabBarItemType_Exclusive) {
        barItem.selected = YES;
        
        [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqual:barItem]) {
                [(FQTabBarItem *)obj setSelected:NO];
            }
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(tabBarView:didSelectItem:index:)]) {
        [self.delegate tabBarView:self didSelectItem:barItem index:[self.items indexOfObject:barItem]];
    }
}




@end
