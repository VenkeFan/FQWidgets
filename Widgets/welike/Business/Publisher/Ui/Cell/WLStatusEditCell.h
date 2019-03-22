//
//  WLStatusEditCell.h
//  welike
//
//  Created by gyb on 2018/11/16.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WLStatusEditCell : UITableViewCell
{
    UIImageView *bgView;
//    UITextView *inputView;
}

@property (copy,nonatomic) NSString *picUrlStr;


-(void)changeBg:(UIImage *)image;

@end
