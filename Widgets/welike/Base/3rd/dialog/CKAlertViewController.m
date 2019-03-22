//
//  CKAlertViewController.m
//  自定义警告框
//
//  Created by 陈凯 on 16/8/24.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CKAlertViewController.h"
#import "YYLabel.h"
#import "AppDelegate.h"

#define kThemeColor [UIColor colorWithRed:94/255.0 green:96/255.0 blue:102/255.0 alpha:1]
#define Dialogheight 172
#define DialogWidth 280

@interface CKAlertAction ()

@property (copy, nonatomic) void(^actionHandler)(CKAlertAction *action);

@end

@implementation CKAlertAction

+ (instancetype)actionWithDeepColorTitle:(NSString *)title handler:(void (^)(CKAlertAction *action))handler {
    CKAlertAction *instance = [CKAlertAction new];
    instance -> _title = title;
    instance.actionHandler = handler;
    instance->_isDeepColor = YES;
    return instance;
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(CKAlertAction *action))handler {
    CKAlertAction *instance = [CKAlertAction new];
    instance -> _title = title;
    instance.actionHandler = handler;
    instance ->_isDeepColor = NO;
    return instance;
}

@end


@interface CKAlertViewController ()
{
    UIView *bgView;
    
    UIView *shadowView;
    UIView *contentView;
    CGFloat contentHeight;
    
    BOOL firstDisplay;
}

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) YYLabel *messageLabel;
@property (strong, nonatomic) NSMutableArray *mutableActions;
@end

@implementation CKAlertViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSMutableAttributedString *)message {
    
    CKAlertViewController *instance = [CKAlertViewController new];
    instance.title = title;
    instance.message = message.mutableString;
    instance.messageAttributedString = message;
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        [self defaultSetting];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //计算出文字的高度
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(DialogWidth - 32, 200) text:self.messageAttributedString];
    contentHeight = layout.textBoundingSize.height;
    
    //mask
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:bgView];
    
    //阴影层
    shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DialogWidth, Dialogheight)];
    shadowView.layer.masksToBounds = NO;
    shadowView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
    shadowView.layer.shadowRadius = 20;
    shadowView.layer.shadowOpacity = 1;
    shadowView.layer.shadowOffset = CGSizeMake(0, 10);
    [self.view addSubview:shadowView];
    shadowView.center = self.view.center;
    
    //内容层
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DialogWidth, 16 + contentHeight + 16 + 40 + 16)];
    contentView.backgroundColor = [UIColor colorWithRed:250 green:251 blue:252 alpha:1];
    contentView.layer.cornerRadius = 5;
    contentView.clipsToBounds = YES;
    [shadowView addSubview:contentView];
    
    //文字
    _messageLabel = [[YYLabel alloc] initWithFrame:CGRectMake(16, 16, DialogWidth - 32,contentHeight)];
    _messageLabel.font = kRegularFont(16);
    _messageLabel.textColor = kDialogFontColor;
    _messageLabel.userInteractionEnabled = YES;
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = _messageAlignment;
    _messageLabel.displaysAsynchronously = YES;
    _messageLabel.attributedText = _messageAttributedString;
    _messageLabel.textLayout = layout;
    [contentView addSubview:_messageLabel];
    
    [self creatAllButtons];

    self.messageLabel.text = self.message;
}

-(void)show
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeKeyWindow];
    
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self.view];
    
    //显示弹出动画
    [self showAppearAnimation];
}


- (void)defaultSetting {
    
    firstDisplay = YES;
    _messageAlignment = NSTextAlignmentCenter;
}

#pragma mark - 创建内部视图
//创建所有按钮
- (void)creatAllButtons {
    
    CGFloat btnWidth = 0;
    CGFloat btnX = 0;
    if (self.actions.count == 1)
    {
        btnWidth = 248;
        btnX = 16;
    }
    
    if (self.actions.count == 2)
    {
         btnWidth = 116;
         btnX = 16;
    }
    
    
    for (int i = 0; i < self.actions.count; i++) {
        
        UIButton *btn = [UIButton new];
        btn.tag = 10 + i;
        btn.titleLabel.font = kBoldFont(16);
        [btn setTitle:self.actions[i].title forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 20;
        [contentView addSubview:btn];
        
        if (self.actions[i].isDeepColor)
        {
            btn.backgroundColor = kMainColor;
            [btn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
        }
        else
        {
            btn.backgroundColor = kSearchEditorColor;
            [btn setTitleColor:kDialogFontColor forState:UIControlStateNormal];
        }
        
        if (self.actions.count == 1)
        {
              btn.frame = CGRectMake(btnX, contentView.height - 56, btnWidth, 40);
        }
        
        if (self.actions.count == 2)
        {
            if (i == 0)
            {
                 btn.frame = CGRectMake(btnX, contentView.height - 56, btnWidth, 40);
            }
            else
            {
                 btn.frame = CGRectMake(16 + btnWidth + 16, contentView.height - 56, btnWidth, 40);
            }
        }
    }
}

#pragma mark - 事件响应
- (void)didClickButton:(UIButton *)sender {
    CKAlertAction *action = self.actions[sender.tag-10];
    if (action.actionHandler) {
        action.actionHandler(action);
    }
    
    [self showDisappearAnimation];
}

#pragma mark - 其他方法

- (void)addAction:(CKAlertAction *)action {
    [self.mutableActions addObject:action];
}

- (UILabel *)creatLabelWithFontSize:(CGFloat)fontSize {
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = kThemeColor;
    return label;
}

- (void)showAppearAnimation {
    
    // __weak typeof(self) weakSelf = self;

    if (firstDisplay) {
        firstDisplay = NO;
        shadowView.alpha = 0;
        shadowView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self->shadowView.transform = CGAffineTransformIdentity;
            self->shadowView.alpha = 1;
        } completion:nil];
    }
    
}

- (void)showDisappearAnimation {
    
  //   __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.1 animations:^{
        self->contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        // [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - getter & setter

- (NSString *)title {
    return [super title];
}

- (NSArray<CKAlertAction *> *)actions {
    return [NSArray arrayWithArray:self.mutableActions];
}

- (NSMutableArray *)mutableActions {
    if (!_mutableActions) {
        _mutableActions = [NSMutableArray array];
    }
    return _mutableActions;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [self creatLabelWithFontSize:20];
        _titleLabel.text = self.title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}


- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
    _message = message;
   // _messageLabel.text = message;
    
    //设置富文本显示,额外加的
}

- (void)setMessageAlignment:(NSTextAlignment)messageAlignment {
    _messageAlignment = messageAlignment;
    _messageLabel.textAlignment = messageAlignment;
}

@end
