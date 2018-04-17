//
//  FQAssetsAlbumView.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/16.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetsAlbumView.h"

@interface FQAssetsAlbumView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray<PHAssetCollection *> *dataArray;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation FQAssetsAlbumView

- (instancetype)initWithDataArray:(NSArray *)dataArray {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        _dataArray = dataArray;
        
        if (_dataArray.count > 0) {
            [self.tableView reloadData];
        }
    }
    return self;
}

#pragma mark - Public

- (void)displayWithAnimation:(void (^)(void))animation {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.transform = CGAffineTransformMakeTranslation(0, TableViewHeight);
                         if (animation) {
                             animation();
                         }
                     }
                     completion:^(BOOL finished) {
                         _displayed = YES;
                     }];
}

- (void)dismissWithAnimation:(void (^)(void))animation {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.transform = CGAffineTransformIdentity;
                         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
                         if (animation) {
                             animation();
                         }
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                         _displayed = NO;
                     }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"FQComboxCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row].localizedTitle;
    cell.textLabel.textColor = kBodyFontColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *album = self.dataArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(assetsAlbumView:didSelectedWithItemModel:)]) {
        [self.delegate assetsAlbumView:self didSelectedWithItemModel:album];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    CGPoint newPoint = [self.tableView convertPoint:point fromView:self];
    if (CGRectContainsPoint(self.tableView.bounds, newPoint)) {
        return NO;
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Event

- (void)selfOnTapped {
    if ([self.delegate respondsToSelector:@selector(assetsAlbumViewDidDismiss:)]) {
        [self.delegate assetsAlbumViewDidDismiss:self];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -ContentViewHeight, kScreenWidth, ContentViewHeight)];
        view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        [self addSubview:view];
        _contentView = view;
    }
    return _contentView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ContentViewHeight - TableViewHeight, kScreenWidth, TableViewHeight)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.rowHeight = DefaultRowHeight;
        [self.contentView addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

@end
