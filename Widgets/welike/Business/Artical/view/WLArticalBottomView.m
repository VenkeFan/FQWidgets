//
//  WLArticalBottomView.m
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalBottomView.h"
#import "WLArticalShareView.h"
#import "WLArticalPostModel.h"

@implementation WLArticalBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        dividingLineView = [[UIView alloc] initWithFrame:CGRectMake(12, 9.5, kScreenWidth - 24, 1)];
        dividingLineView.backgroundColor = kNavShadowColor;
        [self addSubview:dividingLineView];
        
        
        shareLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 60)/2.0, 0, 70, 20)];
        shareLabel.backgroundColor = [UIColor whiteColor];
        shareLabel.font = kRegularFont(12);
      
        shareLabel.textColor = kArticalSecondTitleColor;
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.text = [AppContext getStringForKey:@"share_on" fileName:@"common"];
        [self addSubview:shareLabel];
        
        
        shareView = [[WLArticalShareView alloc] initWithFrame:CGRectMake((kScreenWidth - 235)/2.0, shareLabel.bottom + 10, 235, 65) withBtnWidth:65 haveTitle:YES];
//        shareView.backgroundColor = [UIColor blueColor];
        [self addSubview:shareView];
        
    }
    return self;
}


-(void)setPostBase:(WLArticalPostModel *)postBase
{
    _postBase = postBase;
    shareView.postBase = postBase;
}

@end
