//
//  WLArticalHeaderView.m
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalHeaderView.h"
#import "WLArticalPostModel.h"
#import "WLArticalShareView.h"

@implementation WLArticalHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        

//        UIImageView *dotLine;
        
        tltleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, kScreenWidth - 24, 0)];
        tltleLabel.font = kBoldFont(24);
        tltleLabel.textAlignment = NSTextAlignmentLeft;
//        tltleLabel.backgroundColor = [UIColor orangeColor];
        tltleLabel.numberOfLines = 0;
        tltleLabel.textColor = kArticalTitleColor;
        [self addSubview:tltleLabel];
        
        secondaryTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, kScreenWidth - 24, 14)];
        secondaryTitleLabel.font = kRegularFont(12);
        secondaryTitleLabel.textAlignment = NSTextAlignmentLeft;
//        secondaryTitleLabel.backgroundColor = [UIColor orangeColor];
        secondaryTitleLabel.textColor = kArticalSecondTitleColor;
        secondaryTitleLabel.numberOfLines = 1;
        [self addSubview:secondaryTitleLabel];
        
        
        UIImage *dotImage = [AppContext getImageForKey:@"artical_dot_line"];
        dotLine = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, kScreenWidth - 24, 2)];
        dotLine.image = [dotImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 17)];
        [self addSubview:dotLine];
        
        
        shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 60, 20)];
//        shareLabel.backgroundColor = [UIColor greenColor];
        shareLabel.font = kRegularFont(14);
        shareLabel.text = [AppContext getStringForKey:@"share_on" fileName:@"common"];//@"Share on";
        shareLabel.textColor = kArticalSecondTitleColor;
        [self addSubview:shareLabel];
        
        shareView = [[WLArticalShareView alloc] initWithFrame:CGRectMake(shareLabel.right + 7, 0, 160, 40) withBtnWidth:40 haveTitle:NO];
        [self addSubview:shareView];
    }
    return self;
}

-(void)setPostBase:(WLArticalPostModel *)postBase
{
    _postBase = postBase;
    
    shareView.postBase = postBase;
    
    tltleLabel.text = postBase.title;
    
    CGSize titleSize = [postBase.title sizeWithFont:tltleLabel.font size:CGSizeMake(tltleLabel.width, 100)];
    
    tltleLabel.height = titleSize.height;
    
    secondaryTitleLabel.top = tltleLabel.bottom + 14;
    
    NSString *dateStr = [NSDate fullTimeStringFromTimestamp:postBase.created];
    NSString *countStr;
    if (postBase.readCount > 9999)
    {
        if (postBase.readCount < 9999999)
        {
            countStr = [NSString stringWithFormat:@"%.1fk",postBase.readCount/1000.0];
        }
        else
        {
            countStr = [NSString stringWithFormat:@"%.1fw",postBase.readCount/10000.0];
        }
    }
    else
    {
        countStr = [NSString stringWithFormat:@"%ld",postBase.readCount];
    }
    
    NSString *articalDes = [NSString stringWithFormat:@"%@  %@ %@",dateStr,[AppContext getStringForKey:@"feed_read_count" fileName:@"feed"],countStr];
    
    secondaryTitleLabel.text = articalDes;

    dotLine.top = secondaryTitleLabel.bottom + 5;
    
    shareLabel.top = dotLine.bottom + 20 + (40 - 20)/2.0;
    
    shareView.top = dotLine.bottom + 20;
    
    self.height = dotLine.bottom + 60;
}



@end
