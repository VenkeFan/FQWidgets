//
//  FQEventsViewController.m
//  FQWidgets
//
//  Created by fanqi on 2019/5/16.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQEventsViewController.h"

@interface FQEventsViewController ()

@end

@implementation FQEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor cyanColor];
    view.frame = CGRectMake(20, 120, kScreenWidth - 40, 150);
    [self.view addSubview:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [view addGestureRecognizer:tap];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor purpleColor];
    btn.frame = CGRectMake(0, 0, 100, 45);
    btn.center = CGPointMake(kScreenWidth * 0.5, CGRectGetMaxY(view.frame) + CGRectGetHeight(btn.bounds) + 30);
    [btn setTitle:@"Button" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark - Events

- (void)viewTapped:(UIGestureRecognizer *)gesture {
    NSLog(@"viewTapped: %@", gesture.view);
}

- (void)btnClicked:(UIButton *)sender {
    NSLog(@"btnClicked");
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches: touchesBegan: %@", touches.anyObject.view);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches: touchesEnded: %@", touches.anyObject.view);
}

@end
