//
//  WLLocationCell.h
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLLocationInfo;
@interface WLLocationCell : UITableViewCell
{
    UIImageView *flagView;
    UILabel *locationNameLabel;
    UILabel *locationDetailLabel;
    UIView *lineView;
    
}


@property (strong,nonatomic) WLLocationInfo *locationInfo;
@property (strong,nonatomic) NSString *searchStr;

@end
