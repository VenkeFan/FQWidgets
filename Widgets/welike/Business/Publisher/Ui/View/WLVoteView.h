//
//  WLVoteView.h
//  welike
//
//  Created by gyb on 2018/10/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMJDropdownMenu;
@class WLVoteSingleView;
@class WLAssetModel;
@protocol WLVoteViewDelegate <NSObject>

-(void)addOption:(CGFloat)currentHeight;

-(void)openAlbum:(NSInteger)indexNum;

-(void)allOptionHasbeenFill:(BOOL)isFill;

-(void)optionBeginToInput;
-(void)optionEndInput;

-(void)tapMenu;
-(void)foldMenu;

@end


@interface WLVoteView : UIView
{
    UILabel *timeLabel;
    
    LMJDropdownMenu *dropdownMenu;
    
    UIButton *addBtn;
    
}


@property (assign,nonatomic)  BOOL isPicStatus;//图片状态和文字状态,默认文字状态
@property (assign,nonatomic)  id delegate;
@property (strong,nonatomic)  NSMutableArray *optionViewArray;
@property (strong,nonatomic)  NSMutableArray *optionArray;//选项
@property (strong,nonatomic)  NSMutableArray *imageArray; //选项图
@property (assign,nonatomic)  BOOL isALLFieldFill;
@property (assign,nonatomic) long long time;//ms为单位

-(void)selectVoteImage:(WLAssetModel *)assetModel;
-(BOOL)ifDisableSendBtn;


-(CGFloat)dropdownMenuBottom;



@end


