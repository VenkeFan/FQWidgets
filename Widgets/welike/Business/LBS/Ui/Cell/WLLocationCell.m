//
//  WLLocationCell.m
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationCell.h"
#import "WLLocationInfo.h"

@implementation WLLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        flagView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (44 - 16)/2.0, 16, 16)];
        //flagView.image = [AppContext getImageForKey:@"common_cert"];
        [self addSubview:flagView];
        flagView.hidden = YES;
        
        locationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth - 30, 19)];
        locationNameLabel.font = kRegularFont(16);
        locationNameLabel.textAlignment = NSTextAlignmentLeft;
        locationNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        locationNameLabel.textColor = kNameFontColor;
        locationNameLabel.text = @"";
        [self addSubview:locationNameLabel];
        
        locationDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,locationNameLabel.bottom + 4, kScreenWidth - flagView.right - 7 - 15, 14)];
        locationDetailLabel.font = kMediumFont(12);
        locationDetailLabel.textAlignment = NSTextAlignmentLeft;
        locationDetailLabel.textColor = lbs_detail;
        locationDetailLabel.numberOfLines = 1;
        locationDetailLabel.text = @"";
        locationDetailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:locationDetailLabel];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(13, 54.5, kScreenWidth - 13, 0.5)];
        lineView.backgroundColor = kSeparateLineColor;
        [self addSubview:lineView];
    }
    return self;
}

-(void)setLocationInfo:(WLLocationInfo *)locationInfo
{
    _locationInfo = locationInfo;
    
    if (_locationInfo.userCount == 0)
    {
        locationDetailLabel.text = [AppContext getStringForKey:@"location_empty_view" fileName:@"location"];
    }
    else
    if (_locationInfo.userCount <= 9999)
    {
        locationDetailLabel.text = [NSString stringWithFormat:[AppContext getStringForKey:@"location_has_user" fileName:@"location"],[NSString stringWithFormat:@"%ld",(long)_locationInfo.userCount]];
    }
    else
    if (_locationInfo.userCount > 9999 && _locationInfo.userCount < 10000000)
    {
        NSInteger num = _locationInfo.userCount/1000;
        locationDetailLabel.text = [NSString stringWithFormat:[AppContext getStringForKey:@"location_has_user" fileName:@"location"],[NSString stringWithFormat:@"%ldK",(long)num]];
    }
    else
    {
        NSInteger num = _locationInfo.userCount/10000000;
        locationDetailLabel.text = [NSString stringWithFormat:[AppContext getStringForKey:@"location_has_user" fileName:@"location"],[NSString stringWithFormat:@"%ldM",(long)num]];
    }
}

-(void)setSearchStr:(NSString *)searchStr
{
    _searchStr = searchStr;
    if (_searchStr.length > 0)
    {
        NSRange range = [_locationInfo.name rangeOfString:_searchStr options:NSCaseInsensitiveSearch];
        if (range.length > 0)
        {
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_locationInfo.name];
            [attributedText addAttribute:NSForegroundColorAttributeName value:kMainColor range:range];
            
            locationNameLabel.attributedText = attributedText;
        }
        else
        {
            locationNameLabel.attributedText = [[NSAttributedString alloc] initWithString:_locationInfo.name];
        }
    }
    else
    {
        locationNameLabel.text = _locationInfo.name;
    }
}




@end
