//
//  WLTrendingSearchKeysCell.m
//  welike
//
//  Created by gyb on 2018/8/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingSearchKeysCell.h"
#import "WLTrendingSearchKey.h"
#import "WLTopicSearchSectionView.h"

@interface WLTrendingSearchKeysCell ()

@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArray;

@end

@implementation WLTrendingSearchKeysCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutUI];
    }
    return self;
}



- (void)layoutUI {
    
    UIView *gapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 8)];
    gapView.backgroundColor = kLabelBgColor;
    [self .contentView addSubview:gapView];
    
    sectionView = [[WLTopicSearchSectionView alloc] initWithFrame:CGRectMake(0, gapView.bottom, kScreenWidth, 32)];
    sectionView.titleStr = [AppContext getStringForKey:@"topic_trending_search" fileName:@"common"];
    [self.contentView addSubview:sectionView];
    [sectionView hideLine];
    
    
    NSInteger numberInRow = 2;
    CGFloat width = kScreenWidth / numberInRow, height = 32;
    
    for (int i = 0; i < kDefaultButtonCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.backgroundColor = [UIColor whiteColor];
        btn.frame = CGRectMake((i % numberInRow) * width, (i / numberInRow) * height + sectionView.bottom, width, height);
        [btn setImage:[AppContext getImageForKey:@"topic_hot"] forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
        [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(12);
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 12 + 8, 0, 12)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.numberOfLines = 1;
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        
        [self.btnArray addObject:btn];
    }
    
    UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2.0, sectionView.bottom , 1, 64)];
    vLine.backgroundColor = kSeparateLineColor;
    [self.contentView addSubview:vLine];
}

#pragma mark - Public

- (void)setDataArray:(NSArray<WLTrendingSearchKey *> *)dataArray {
    _dataArray = dataArray;

    NSInteger count = dataArray.count;
    count = count > kDefaultButtonCount ? kDefaultButtonCount : count;

    for (int i = 0; i < count; i++) {
        WLTrendingSearchKey *model = dataArray[i];
        NSString *title = model.words;
        [self.btnArray[i] setTitle:title forState:UIControlStateNormal];
    }
}

#pragma mark - Event

- (void)btnClicked:(UIButton *)sender {
    NSInteger index = sender.tag;

    if (index >= self.dataArray.count) {
        return;
    }

      WLTrendingSearchKey *model = _dataArray[index];
    
    if ([self.delegate respondsToSelector:@selector(didClickKey:)]) {
        [self.delegate didClickKey:model.words];
    }
}

#pragma mark - Getter

- (NSMutableArray<UIButton *> *)btnArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}



@end
