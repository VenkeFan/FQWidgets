//
//  WLTopicThumbView.m
//  welike
//
//  Created by gyb on 2018/8/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicThumbView.h"
#import "LuuUtils.h"
#import "UIImageView+WebCache.h"

@implementation WLTopicThumbView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      
        thumbView1 = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, frame.size.height, frame.size.height)];
        thumbView1.contentMode =  UIViewContentModeScaleAspectFill;
        thumbView1.clipsToBounds = YES;
       thumbView1.layer.cornerRadius = 4;
        [self addSubview:thumbView1];
        thumbView1.hidden = YES;
        
        thumbView2 = [[UIImageView alloc] initWithFrame:CGRectMake(thumbView1.right + 6, 0, frame.size.height, frame.size.height)];
        thumbView2.contentMode =  UIViewContentModeScaleAspectFill;
         thumbView2.clipsToBounds = YES;
        thumbView2.clipsToBounds = YES;
        thumbView2.layer.cornerRadius = 4;
        [self addSubview:thumbView2];
        thumbView2.hidden = YES;
        
        
        thumbView3 = [[UIImageView alloc] initWithFrame:CGRectMake(thumbView2.right + 6, 0, frame.size.height, frame.size.height)];
        thumbView3.contentMode =  UIViewContentModeScaleAspectFill;
        thumbView3.clipsToBounds = YES;
        thumbView3.clipsToBounds = YES;
       thumbView3.layer.cornerRadius = 4;
        [self addSubview:thumbView3];
        thumbView3.hidden = YES;
        
        thumbView4 = [[UIImageView alloc] initWithFrame:CGRectMake(thumbView3.right + 6, 0, frame.size.height, frame.size.height)];
        thumbView4.contentMode =  UIViewContentModeScaleAspectFill;
         thumbView4.clipsToBounds = YES;
       thumbView4.clipsToBounds = YES;
        thumbView4.layer.cornerRadius = 4;
        [self addSubview:thumbView4];
        thumbView4.hidden = YES;
        
        thumbArray = [NSArray arrayWithObjects:thumbView1,thumbView2,thumbView3,thumbView4,nil];
        
        
    }
    return self;
}


-(void)setPics:(NSArray *)pics
{
    _pics = pics;
    
    for (int i = 0; i < thumbArray.count; i++)
    {
        UIImageView *thumbView = thumbArray[i];
        thumbView.hidden = YES;
        thumbView.image = nil;
    }
    
    NSInteger count = (_pics.count > 4)?4:_pics.count;
    
    for (int i = 0; i < count; i++)
    {
        
        UIImageView *thumbView = thumbArray[i];
        NSString *picStr = [LuuUtils getThumbnailPicUrl:_pics[i] strategy:kThumbnailStrategyMFit width:thumbView.width*3 height:thumbView.height*3];
        thumbView.hidden = NO;
        
        [thumbView fq_setImageWithURLString:picStr placeholder:nil cornerRadius:0 completed:^(UIImage *image, NSURL *url, NSError *error) {
        }];
    }
}


@end
