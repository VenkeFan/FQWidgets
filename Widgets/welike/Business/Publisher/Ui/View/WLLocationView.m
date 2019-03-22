//
//  WLLocationView.m
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationView.h"

@implementation WLLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//         self.backgroundColor = kUIColorFromRGBA(0x859EBC,0.1);
//         self.layer.cornerRadius = 2;
        
        UIImage *locationFlag = [AppContext getImageForKey:@"publish_location"];
        
        UIImageView *flagView = [[UIImageView alloc]  initWithFrame:CGRectMake(10, (frame.size.height - locationFlag.size.height)/2.0, locationFlag.size.width, locationFlag.size.height)];
        flagView.image = locationFlag;
        [self addSubview:flagView];
        
        locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        locationBtn.frame = CGRectMake(0, (frame.size.height - 24)/2.0 , 95, 24);
        locationBtn.backgroundColor = kUIColorFromRGBA(0x859EBC,0.1);
        locationBtn.layer.cornerRadius = 3;
        [locationBtn addTarget:self action:@selector(locationBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:locationBtn];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(flagView.right + 10, 0, self.frame.size.width - flagView.width - 10, frame.size.height)];
        locationLabel.textColor = kClickableTextColor;
        locationLabel.text = [AppContext getStringForKey:@"editor_location_null" fileName:@"publish"];
        locationLabel.font = kRegularFont(12);
        locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:locationLabel];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(0, 0 , 35, frame.size.height);
//        deleteBtn.backgroundColor = [UIColor greenColor];
        [deleteBtn setImage:[AppContext getImageForKey:@"location_del"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        deleteBtn.hidden = YES;
        
        
    }
    return self;
}

-(void)locationBtnPressed
{
    [_delegate locationBtnPressed];
}


-(void)changeLocvationName:(NSString *)locationStr
{
    locationLabel.text = locationStr;
    
 
    
    CGSize textSize = [locationStr sizeWithFont:locationLabel.font size:CGSizeMake(self.width - 10 - 10 - 20, self.height)];
    
    locationLabel.width = textSize.width;
    
    deleteBtn.left = locationLabel.right - 8;
    deleteBtn.hidden = NO;
    
    locationBtn.width = locationLabel.left + locationLabel.width + 25;
}

-(void)deleteBtnPressed
{
    deleteBtn.hidden = YES;
    
    locationBtn.width =  95;
    
    locationLabel.width =  self.width - 10 - 10 - 20;
    
    locationLabel.text = [AppContext getStringForKey:@"editor_location_null" fileName:@"publish"];
    
    [_delegate locationDeleteBtnPressed];
}


@end
