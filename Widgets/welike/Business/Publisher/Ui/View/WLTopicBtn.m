//
//  WLTopicBtn.m
//  welike
//
//  Created by gyb on 2018/11/7.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTopicBtn.h"

@implementation WLTopicBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        self.backgroundColor = kUIColorFromRGBA(0x859EBC,0.1);
//        self.layer.cornerRadius = 2;
        
        titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 5, frame.size.height)];
        titleLable.font = kBoldFont(14);
        titleLable.textColor = kDeepOrangeColor;
        titleLable.textAlignment = NSTextAlignmentLeft;
        titleLable.text = [AppContext getStringForKey:@"new_topic_title" fileName:@"publish"];
        [self addSubview:titleLable];
        
        CGSize labelSize = [titleLable.text sizeWithFont:titleLable.font size:CGSizeMake(150, frame.size.height)];
        titleLable.width = labelSize.width;
        

        UIImage *triangleImage = [AppContext getImageForKey:@"publish_triangle"];
        triangleView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLable.right + 2, (frame.size.height - triangleImage.size.height)/2.0, triangleImage.size.width, triangleImage.size.height)];
        triangleView.image = triangleImage;
        
        [titleLable addSubview:triangleView];
    }
    return self;
}

-(void)changeToEnable
{
    UIImage *triangleImage = [AppContext getImageForKey:@"publish_triangle"];
    titleLable.textColor = kDeepOrangeColor;
    self.enabled = YES;
    triangleView.image = triangleImage;
}


-(void)changeToDisable
{
    UIImage *triangleImage = [AppContext getImageForKey:@"publish_triangle_dis"];
    titleLable.textColor = kLightLightFontColor;
    self.enabled = NO;
    triangleView.image = triangleImage;
}

@end
