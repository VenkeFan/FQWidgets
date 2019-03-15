//
//  FQHtmlLabelViewController.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/5.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlLabelViewController.h"
#import "FQHtmlLabel.h"

@interface FQHtmlLabelViewController () <FQHtmlLabelDelegate>

@property (nonatomic, strong) FQHtmlLabel *htmlLabel;

@end

@implementation FQHtmlLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _htmlLabel = [[FQHtmlLabel alloc] init];
    _htmlLabel.htmlDelegate = self;
    _htmlLabel.typingAttributes = @{NSFontAttributeName: kRegularFont(26), NSForegroundColorAttributeName: kUIColorFromRGB(0x616161)};
    _htmlLabel.linkTextAttributes = @{NSUnderlineStyleAttributeName: @(YES),
                                      NSForegroundColorAttributeName: [UIColor redColor]};
    _htmlLabel.backgroundColor = [UIColor lightGrayColor];
    _htmlLabel.frame = CGRectMake(12, 12, kScreenWidth - 24, kScreenHeight - 12 - kSafeAreaBottomY - kNavBarHeight - 200);
    _htmlLabel.layer.borderWidth = 1.0;
    _htmlLabel.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:_htmlLabel];
    
    NSURL *testFileUrl = [[NSBundle mainBundle] URLForResource:@"index2" withExtension:@"html"];
    NSData *data = [NSData dataWithContentsOfURL:testFileUrl];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: kRegularFont(16), NSForegroundColorAttributeName: [UIColor cyanColor]}];
//    _txtView.attributedText = attrStr;
    
    _htmlLabel.text = str;
}

#pragma mark - FQHtmlLabelDelegate

- (void)htmlLabel:(FQHtmlLabel *)htmlLabel didHighlight:(FQHtmlHighlight *)highlight {
    
}

@end
