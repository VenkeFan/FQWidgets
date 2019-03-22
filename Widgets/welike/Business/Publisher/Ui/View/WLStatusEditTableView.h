//
//  WLStatusEditTableView.h
//  welike
//
//  Created by gyb on 2018/11/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLStatusInfo;
@class WLStatusEditCell;

@protocol WLStatusEditTableViewDelegate <NSObject>


- (void)endEdit;


@end

@interface WLStatusEditTableView : UITableView
{
//    UITextView *inputView;
}

@property (strong,nonatomic) WLStatusInfo *statusInfo;
@property (weak,nonatomic) id editDelegate;

-(void)changeToIndex:(NSInteger)index;

-(void)changeCustomImage:(UIImage *)image;


-(NSString *)currentPicUrl;

-(WLStatusEditCell *)currentCell;

@end

