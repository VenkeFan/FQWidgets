//
//  WLStatusSelectBgCell.h
//  welike
//
//  Created by gyb on 2018/11/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLStatusSelectBgCell : UITableViewCell
{
    UIImageView *bgView;
    //    UITextView *inputView;
}

@property (copy,nonatomic) NSString *picUrlStr;

@end

NS_ASSUME_NONNULL_END
