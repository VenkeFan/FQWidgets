//
//  WLResidentTopicCell.m
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLResidentTopicCell.h"
#import "WLTopicInfoModel.h"

@interface WLResidentTopicCell ()

@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArray;

@end

@implementation WLResidentTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    NSInteger numberInRow = 2;
    CGFloat width = kScreenWidth / numberInRow, height = kWLResidentTopicContentHeight * 0.5;
    
    for (int i = 0; i < kDefaultButtonCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.backgroundColor = [UIColor whiteColor];
        btn.frame = CGRectMake((i % numberInRow) * width, (i / numberInRow) * height, width, height);
        [btn setImage:[AppContext getImageForKey:@"topic_hot"] forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
        [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kMediumNameFontSize);
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 12 + 8, 0, 12)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.numberOfLines = 1;
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        
        [self.btnArray addObject:btn];
    }
    
    UIView *hSeparateLine = [[UIView alloc] initWithFrame:CGRectMake(0, kWLResidentTopicContentHeight - 1.0, kScreenWidth, 1.0)];
    hSeparateLine.backgroundColor = kSeparateLineColor;
    [self.contentView addSubview:hSeparateLine];
    
    UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, kWLResidentTopicContentHeight - 16)];
    vLine.backgroundColor = kSeparateLineColor;
    vLine.center = CGPointMake(kScreenWidth * 0.5, kWLResidentTopicContentHeight * 0.5);
    [self.contentView addSubview:vLine];
}

#pragma mark - Public

- (void)setDataArray:(NSArray<WLTopicInfoModel *> *)dataArray {
    _dataArray = dataArray;
    
    NSInteger count = dataArray.count;
    count = count > kDefaultButtonCount ? kDefaultButtonCount : count;
    
    for (int i = 0; i < count; i++) {
        WLTopicInfoModel *topicModel = dataArray[i];
        NSString *title = topicModel.topicName;
        [self.btnArray[i] setTitle:title forState:UIControlStateNormal];
    }
}

#pragma mark - Event

- (void)btnClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    
    if (index >= self.dataArray.count) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(residentTopicCell:didClickedTopic:)]) {
        [self.delegate residentTopicCell:self didClickedTopic:self.dataArray[index].topicID];
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
