//
//  WLAboutPersonListTableViewCell.h
//  welike
//
//  Created by gyb on 2018/5/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>



@class WLContact;
@class WLHeadView;
@interface WLContactPersonListTableViewCell : UITableViewCell
{
    WLHeadView *avatar;
    UILabel *nameLabel;
    UIView *lineView;
    
    
}

@property (nonatomic,strong) WLContact *contact;

@property (nonatomic,strong) NSString *searchStr;


@end
