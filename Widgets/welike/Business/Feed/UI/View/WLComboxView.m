//
//  WLComboxView.m
//  welike
//
//  Created by fan qi on 2019/2/27.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLComboxView.h"
#import "WLImageButton.h"

#define kComboxCellTop              8.0
#define kComboxCellHeight           34.0

static NSString * const reuseComboxCellID = @"WLComboxTableViewCellID";

@interface WLComboxView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign, readwrite) BOOL displayList;
@property (nonatomic, strong) WLImageButton *titleBtn;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WLComboxView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _titleBtn = [[WLImageButton alloc] initWithFrame:frame];
        _titleBtn.imageOrientation = WLImageButtonOrientation_Right;
        _titleBtn.selected = NO;
        [_titleBtn setTitleColor:kUIColorFromRGB(0x48779D) forState:UIControlStateNormal];
        _titleBtn.tintColor = kUIColorFromRGB(0x48779D);
        _titleBtn.titleLabel.font = kRegularFont(kLightFontSize);
        UIImage *iconImg = [AppContext getImageForKey:@"publish_triangle_dis"];
        iconImg = [iconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_titleBtn setImage:iconImg forState:UIControlStateNormal];
        [_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_titleBtn addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tableView.frame = _containerView.bounds;
}

#pragma mark - Public

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    if (!_containerView) {
        CGFloat height = dataArray.count > 5 ? (5 * kComboxCellHeight + kComboxCellTop * 2) : (dataArray.count * kComboxCellHeight + kComboxCellTop * 2);
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.alpha = 0.0;
        _containerView.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
        _containerView.layer.shadowOffset = CGSizeMake(0, 3);
        _containerView.layer.shadowOpacity = 0.25;
        _containerView.layer.shadowPath = CGPathCreateWithRect(_containerView.frame, NULL);
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseComboxCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.layer.cornerRadius = kCornerRadius;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        [_containerView addSubview:_tableView];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kComboxCellTop;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kComboxCellTop;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kComboxCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseComboxCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.textColor = kBodyFontColor;
    cell.textLabel.font = kRegularFont(kMediumNameFontSize);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    if (indexPath.row == self.currentIndex) {
        cell.backgroundColor = kUIColorFromRGB(0xF4F4F4);
    } else {
        cell.backgroundColor = kUIColorFromRGB(0xFFFFFF);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setCurrentIndex:indexPath.row];
    [self setDisplayList:NO];
    [self.tableView reloadData];
}

#pragma mark - Event

- (void)titleBtnClicked:(WLImageButton *)sender {
    [self setDisplayList:!self.displayList];
}

- (void)bgViewTapped {
    [self setDisplayList:NO];
}

#pragma mark - Setter

- (void)setDisplayList:(BOOL)displayList {
    _displayList = displayList;
    
    if (displayList) {
        CGRect absoluteFrame = [self.titleBtn convertRect:self.titleBtn.frame toView:kCurrentWindow];
        CGRect tbFrame = self.containerView.frame;
        tbFrame.origin.x = absoluteFrame.origin.x;
        tbFrame.origin.y = CGRectGetMaxY(absoluteFrame);
        self.containerView.frame = tbFrame;
        
        [kCurrentWindow addSubview:self.bgView];
        [kCurrentWindow addSubview:self.containerView];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.titleBtn.imageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                             self.containerView.alpha = 1.0;
                         }];
    } else {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.titleBtn.imageView.transform = CGAffineTransformIdentity;
                             self.containerView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.containerView removeFromSuperview];
                             [self.bgView removeFromSuperview];
                         }];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        
        if ([self.delegate respondsToSelector:@selector(comboxView:indexChanged:)]) {
            [self.delegate comboxView:self indexChanged:currentIndex];
        }
    }
    
    _currentIndex = currentIndex;
    [self.titleBtn setTitle:self.dataArray[currentIndex] forState:UIControlStateNormal];
}

#pragma mark - Getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:kCurrentWindow.bounds];
        _bgView.backgroundColor = kUIColorFromRGBA(0x000000, 0.0);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTapped)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}

@end
