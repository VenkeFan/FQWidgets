//
//  WLFieldKindCellDelegate.h
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLFieldKindCellDelegate <NSObject>

@optional
- (void)cellIndexDidBeginEditing:(NSIndexPath *)indexPath;
- (void)cellIndex:(NSIndexPath *)indexPath didEndEditingWithContent:(NSString *)content;
- (BOOL)cellIndex:(NSIndexPath *)indexPath textFieldText:(NSString *)textFieldText shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)cellIndexShouldClear:(NSIndexPath *)indexPath;

@end
