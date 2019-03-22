//
//  WLUnloginBannerCell.m
//  welike
//
//  Created by gyb on 2018/8/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnloginBannerCell.h"
#import "WLTopicInfoModel.h"
#import "UIImageView+WebCache.h"

#define CollectionCell @"WLSlidingCell"


@implementation WLUnloginBannerCell

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

    CWFlowLayout *flowLayout = [[CWFlowLayout alloc] initWithStyle:CWCarouselStyle_H_1];
    flowLayout.itemWidth = 306;
    flowLayout.itemSpace_H = 14;
    
    CWCarousel *carousel = [[CWCarousel alloc] initWithFrame:CGRectMake(0, 8 + 8.5,kScreenWidth, 95)
                                                    delegate:self
                                                  datasource:self
                                                  flowLayout:flowLayout];
    carousel.isAuto = YES;
    carousel.pageControl.hidden = YES;
    carousel.backgroundColor = [UIColor whiteColor];
    [self addSubview:carousel];
    [carousel registerViewClass:[UICollectionViewCell class] identifier:CollectionCell];
    self.carousel = carousel;
}


-(void)setBanners:(NSArray *)banners
{
    _banners = banners;
    
    [self.carousel freshCarousel];
}

- (NSInteger)numbersForCarousel {
    return _banners.count;
}

#pragma mark - CWCarouselDelegate
- (UICollectionViewCell *)viewForCarousel:(CWCarousel *)carousel indexPath:(NSIndexPath *)indexPath index:(NSInteger)index{
    UICollectionViewCell *cell = [carousel.carouselView dequeueReusableCellWithReuseIdentifier:CollectionCell forIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor cyanColor];
    UIImageView *imageView = [cell.contentView viewWithTag:1004];
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 1004;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
                cell.layer.masksToBounds = YES;
                cell.layer.cornerRadius = 4;
    }
    
    WLTopicInfoModel *model = _banners[index];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.bannerUrl]];
    
    return cell;
}

- (void)CWCarousel:(CWCarousel *)carousel didSelectedAtIndex:(NSInteger)index {
    WLTopicInfoModel *model = _banners[index];
    
    if ([self.delegate respondsToSelector:@selector(didSelctbanner:)]) {
        [self.delegate didSelctbanner:model.topicID];
    }
}

@end
