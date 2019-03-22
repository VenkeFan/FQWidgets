//
//  WLLocationTopView.m
//  welike
//
//  Created by gyb on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationTopView.h"
#import "WLUser.h"
#import "WLLocationDetail.h"
#import "WLHeadView.h"

#define marginX                             12
#define marginY                             15
#define defaultDisplayUsersCount            6

@implementation WLLocationTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        bgImgView = [[UIImageView alloc] init];
        bgImgView.frame = CGRectMake(0, 0, kScreenWidth, kWLTopicInfoContentHeight);
        bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        bgImgView.clipsToBounds = YES;
        [self addSubview:bgImgView];
        
        shadeLayer = [CALayer layer];
        shadeLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        shadeLayer.frame = bgImgView.frame;
        [self.layer addSublayer:shadeLayer];
     
        
        UIImage *locationFlag = [AppContext getImageForKey:@"location_detail_flag"];
        
        locationFlagView = [[UIImageView alloc] initWithFrame:CGRectMake(marginX, 17, locationFlag.size.width, locationFlag.size.height)];
        locationFlagView.image = locationFlag;
        [self addSubview:locationFlagView];
        locationFlagView.hidden = YES;
        
        placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 16, kScreenWidth - 30 - 12, 26)];
        placeLabel.textColor = [UIColor whiteColor];
        placeLabel.font = kBoldFont(24);
        placeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:placeLabel];
        
        useountLayer = [self textLayerWithFont:kBoldFont(16) textColor:[UIColor whiteColor]];
        useountLayer.frame = CGRectMake(marginX, placeLabel.bottom + 6, kScreenWidth - marginX*2, 16);
        [self.layer addSublayer:useountLayer];
        
        CGFloat width = 120, height = 36;
        usersView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - width, 80, width, height)];
//        usersView.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usersViewOnTapped)];
        [usersView addGestureRecognizer:tap];
        [self addSubview:usersView];
    }
    return self;
}

-(void)setUserArray:(NSArray *)userArray
{
    if (userArray.count == 0 || [_userArray isEqual:userArray]) {
        return;
    }
    
    _userArray = userArray;
    
    [usersView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [usersView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
//    CGFloat fontSize = 14, height = fontSize + 3, width = 40;

    
    CGFloat size = 28;
    CGFloat x = 4, y = (CGRectGetHeight(usersView.bounds) - size) / 2.0;
    CGFloat paddingX = -5;
    NSInteger count = userArray.count > defaultDisplayUsersCount ? defaultDisplayUsersCount : userArray.count;
    
    CGFloat userViewWidth = (count + 1)*28 + 5 - count * 3;
    usersView.width = userViewWidth;
    usersView.left = kScreenWidth - userViewWidth;
    
    
    for (int i = 0; i < count; i++) {
        WLUser *user = (WLUser *)userArray[i];
        
        WLHeadView *imgView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        imgView.frame = CGRectMake(x, y, size, size);
        imgView.userInteractionEnabled = NO;
        [imgView setHeadUrl:user.headUrl];
        [usersView addSubview:imgView];
        
        x += (size + paddingX);
    }
    
    //再额外加一个
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(userViewWidth - 5 - 28 - 7, y, size, size)];
    allLabel.font = kBoldFont(12) ;
    allLabel.textColor = kClickableTextColor;
    allLabel.text = [AppContext getStringForKey:@"all" fileName:@"common"];
    allLabel.layer.cornerRadius = size/2;
    allLabel.clipsToBounds = YES;
    allLabel.textAlignment = NSTextAlignmentCenter;
    allLabel.backgroundColor = [UIColor whiteColor];
    [usersView addSubview:allLabel];
}

-(void)setLocationDetail:(WLLocationDetail *)locationDetail
{
    _locationDetail = locationDetail;
    
    locationFlagView.hidden = NO;
    
    [bgImgView fq_setImageWithURLString:[locationDetail.photo convertToHttps] placeholder:[AppContext getImageForKey:@"location_bg"]];
    
    NSString *userNumStr;
    
    if (locationDetail.userCount > 0)
    {
        userNumStr = [NSString stringWithFormat:@"%ld",(long)locationDetail.userCount];
    }
    else
    if (locationDetail.userCount > 9999 && locationDetail.userCount < 10000000)
    {
        userNumStr = [NSString stringWithFormat:@"%ldK",(long)(locationDetail.userCount/1000)];
    }
    else
    {
        userNumStr = [NSString stringWithFormat:@"%ldM",(long)(locationDetail.userCount/1000000)];
    }
    
    
    if (locationDetail.userCount == 0)
    {
         useountLayer.string = [NSString stringWithFormat:[AppContext getStringForKey:@"location_no_user" fileName:@"location"], userNumStr];
    }
    else
    {
         useountLayer.string = [NSString stringWithFormat:[AppContext getStringForKey:@"location_has_user" fileName:@"location"], userNumStr];
    }
    
    placeLabel.text = locationDetail.placeName;
}


#pragma mark - Event

- (void)usersViewOnTapped {
    if ([self.delegate respondsToSelector:@selector(didClickedUsers)]) {
        [self.delegate didClickedUsers];
    }
}


- (CATextLayer *)textLayerWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.contentsScale = kScreenScale;
    txtLayer.alignmentMode = kCAAlignmentJustified;
    txtLayer.truncationMode = kCATruncationEnd;
    txtLayer.foregroundColor = textColor.CGColor;
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    txtLayer.font = fontRef;
    txtLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    return txtLayer;
}



@end
