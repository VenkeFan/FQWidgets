//
//  WLTrendingUserCell.m
//  welike
//
//  Created by gyb on 2018/8/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingUserCell.h"
#import "WLTopicSearchSectionView.h"
#import "WLTrendingUserScrollView.h"
#import "WLTrendingUserModel.h"

@implementation WLTrendingUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
      
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        sectionView = [[WLTopicSearchSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 32)];
        sectionView.titleStr = [AppContext getStringForKey:@"topic_trending_people" fileName:@"common"];
        [self.contentView addSubview:sectionView];
        [sectionView hideLine];
        
        
        UIImage *indicateImage = [AppContext getImageForKey:@"common_arrow_right_orange"];
        UIImageView *indicateView = [[UIImageView alloc] initWithFrame:CGRectMake(sectionView.right - 20, (sectionView.height - indicateImage.size.height)/2.0, indicateImage.size.width, indicateImage.size.height)];
        indicateView.image = indicateImage;
        [sectionView addSubview:indicateView];
        
        
        trendingUserScrollView = [[WLTrendingUserScrollView alloc] initWithFrame:CGRectMake(0, 36, kScreenWidth, 57)];
        trendingUserScrollView.target = self;
        [self.contentView addSubview:trendingUserScrollView];
    }
    return self;
}


-(void)setTrendingUserModel:(WLTrendingUserModel *)trendingUserModel
{
    _trendingUserModel = trendingUserModel;
    
    trendingUserScrollView.dataArray = _trendingUserModel.users;
}


- (void)onClick:(WLHeadView *)headView
{
    [_delegate didSelctUser:headView.user.uid];
}





@end
