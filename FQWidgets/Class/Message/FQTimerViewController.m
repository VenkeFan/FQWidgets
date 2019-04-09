//
//  FQTimerViewController.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/24.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQTimerViewController.h"
#import "FQTimerManager.h"

@interface FQTimerViewController ()

@property (nonatomic, strong) FQTimerManager *timerManager;

@end

@implementation FQTimerViewController

- (void)loadView {
    NSLog(@"loadView");
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    NSLog(@"viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _timerManager = [[FQTimerManager alloc] initWithTarget:self
                                                 aSelector:@selector(timerStep)];
    
    __weak typeof(self) weakSelf = self;
    UIButton *startBtn = [self buttonWithTitle:@"开始" block:^(id sender) {
        [weakSelf.timerManager start];
    }];
    [self.view addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.top.mas_equalTo(self.view).offset(kNavBarHeight);
        make.size.mas_equalTo(CGSizeMake(120, 45));
    }];

    UIButton *pauseBtn = [self buttonWithTitle:@"暂停" block:^(id sender) {
        [weakSelf.timerManager pause];
    }];
    [self.view addSubview:pauseBtn];
    [pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.top.mas_equalTo(startBtn.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(120, 45));
    }];
}

- (void)dealloc {
    NSLog(@"FQTimerViewController dealloc !!!!!!");
    
    [_timerManager shutdown];
}

- (void)timerStep {
    NSLog(@"------> timerStep");
}

#pragma mark - Getter

- (UIButton *)buttonWithTitle:(NSString *)title block:(void(^)(id sender))block {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addBlockForControlEvents:UIControlEventTouchUpInside block:block];
    
    return btn;
}

@end
