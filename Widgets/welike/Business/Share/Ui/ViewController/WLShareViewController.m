//
//  WLShareViewController.m
//  welike
//
//  Created by fan qi on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLShareViewController.h"
#import "WLShareManager.h"
#import "WLImageButton.h"

#define kWhatsAppName               @"WhatsApp"
#define kFacebookName               @"Facebook"
#define kCopyLinkName               @"Copy"

@interface WLShareViewController ()

@property (nonatomic, strong) WLShareManager *shareManager;

@end

@implementation WLShareViewController

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutUI {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kSafeAreaBottomY - 142, kScreenWidth, kSafeAreaBottomY + 142)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:contentView.bounds
                                               byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                     cornerRadii:CGSizeMake(8, CGRectGetHeight(contentView.bounds))];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = contentView.bounds;
    shapeLayer.path = path.CGPath;
    contentView.layer.mask = shapeLayer;
    
    
    UIButton *titleBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, kScreenWidth, 48);
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"] forState:UIControlStateNormal];
        [btn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kNameFontSize);

        btn;
    });
    [contentView addSubview:titleBtn];
    
    UIScrollView *scrollView = ({
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleBtn.frame), kScreenWidth, CGRectGetHeight(contentView.frame) - CGRectGetMaxY(titleBtn.frame))];
        sv.backgroundColor = [UIColor whiteColor];
        sv.showsVerticalScrollIndicator = NO;
        sv.showsHorizontalScrollIndicator = NO;
        sv.contentSize = CGSizeMake(CGRectGetWidth(sv.frame) + 1, 0);
        
        CGFloat x = 10, paddingX = 10;
        
        UIControl *whatsBtn = [self buttonWithTitle:kWhatsAppName imageName:@"share_whats" x:x action:@selector(whatsBtnOnClicked)];
        [sv addSubview:whatsBtn];
        x += (whatsBtn.frame.size.width + paddingX);
        
        UIControl *fbBtn = [self buttonWithTitle:kFacebookName imageName:@"share_facebook" x:x action:@selector(facebookBtnOnClicked)];
        [sv addSubview:fbBtn];
        x += (fbBtn.frame.size.width + paddingX);
        
        UIControl *copyBtn = [self buttonWithTitle:kCopyLinkName imageName:@"share_link" x:x action:@selector(copyBtnOnClicked)];
        [sv addSubview:copyBtn];
        
        sv;
    });
    [contentView addSubview:scrollView];
}

- (UIControl *)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName x:(CGFloat)x action:(SEL)action {
    WLImageButton *btn = [[WLImageButton alloc] init];
    btn.frame = CGRectMake(x, 0, 65, 75);
    btn.imageOrientation = WLImageButtonOrientation_Top;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
    btn.titleLabel.font = kRegularFont(12);
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setImage:[AppContext getImageForKey:imageName] forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(8, 0, 0, 0)];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

#pragma mark - Public

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Event

- (void)whatsBtnOnClicked {
    if (!self.shareModel) {
        return;
    }
    
    [self.shareManager whatsAppShareWithShareModel:self.shareModel];
}

- (void)facebookBtnOnClicked {
    if (!self.shareModel) {
        return;
    }
    
    [self.shareManager facebookShareWithShareModel:self.shareModel];
}

- (void)copyBtnOnClicked {
    if (!self.shareModel) {
        return;
    }
    
    [self.shareManager copyLinkWithShareModel:self.shareModel];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

#pragma mark - Getter

- (WLShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[WLShareManager alloc] init];
        _shareManager.currentViewCtr = self;
    }
    return _shareManager;
}

@end
