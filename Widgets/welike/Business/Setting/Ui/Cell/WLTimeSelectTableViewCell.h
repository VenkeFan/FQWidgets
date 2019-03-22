//
//  WLTimeSelectTableViewCell.h
//  welike
//
//  Created by luxing on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLTimeSelectViewModel.h"

@interface WLTimeSelectTableViewCell : UITableViewCell

- (void)setDataSourceItem:(WLTimeSelectViewModel *)item;

@end
