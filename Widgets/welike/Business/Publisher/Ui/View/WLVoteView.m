//
//  WLVoteView.m
//  welike
//
//  Created by gyb on 2018/10/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVoteView.h"
#import "WLVoteSingleView.h"
#import "LMJDropdownMenu.h"
#import "WLAssetModel.h"

@interface WLVoteView () <LMJDropdownMenuDelegate,WLVoteSingleViewDelegate>
{
    NSInteger currentVoteIndex;
}
@end

@implementation WLVoteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _optionViewArray = [[NSMutableArray alloc] initWithCapacity:0];
        _optionArray = [[NSMutableArray alloc] initWithCapacity:0];
        _time = 3*24*3600;//默认3天
        
        for (int i = 0; i < 2; i++)
        {
            WLVoteSingleView *voteSingleView = [[WLVoteSingleView alloc] initWithFrame:CGRectMake(15,i*48, kScreenWidth, 48)];
            voteSingleView.placeHolderStr = [NSString stringWithFormat:[AppContext getStringForKey:@"option_num" fileName:@"publish"],i + 1];
            voteSingleView.deleteBtnEnable = NO;
            voteSingleView.delegate = self;
            voteSingleView.type = 0;
            [self addSubview:voteSingleView];
            [_optionViewArray addObject:voteSingleView];
        }
        
        WLVoteSingleView *lastVoteView = _optionViewArray.lastObject;
        
        NSString *timeLabelContent =  [AppContext getStringForKey:@"Poll_time" fileName:@"publish"];
        CGSize timeLabelSize = [timeLabelContent sizeWithFont:kRegularFont(14) size:CGSizeMake(150, 20)];
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, lastVoteView.bottom, timeLabelSize.width, 32)];
        timeLabel.textColor = kBodyFontColor;
        timeLabel.text = timeLabelContent;
        timeLabel.font = kRegularFont(14);
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:timeLabel];
        
        NSArray *timeArray = [NSArray arrayWithObjects:
                              [AppContext getStringForKey:@"one_day" fileName:@"publish"],
                              [AppContext getStringForKey:@"three_day" fileName:@"publish"],
                              [AppContext getStringForKey:@"seven_day" fileName:@"publish"],
                              [AppContext getStringForKey:@"one_month" fileName:@"publish"],
                              [AppContext getStringForKey:@"no_time_limit" fileName:@"publish"],nil];
        
        
        dropdownMenu = [[LMJDropdownMenu alloc] init];
        [dropdownMenu setFrame:CGRectMake(timeLabel.right + 5, lastVoteView.bottom, 170, 32)];
        [dropdownMenu setMenuTitles:timeArray rowHeight:32];
        dropdownMenu.delegate = self;
        [self addSubview:dropdownMenu];
        
        addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(kScreenWidth - 34 - 10, timeLabel.top, 34, 30);
        [addBtn setImage:[AppContext getImageForKey:@"post_add_option"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addBtn];
    }
    return self;
}

-(CGFloat)dropdownMenuBottom
{
    return dropdownMenu.bottom;
}


-(void)setIsPicStatus:(BOOL)isPicStatus
{
    _isPicStatus = isPicStatus;
    
    [self resetFrame];
}

-(void)selectVoteImage:(WLAssetModel *)assetModel
{
    WLVoteSingleView *voteSingleView = _optionViewArray[currentVoteIndex];
    voteSingleView.assetModel = assetModel;
    
    //变成四宫格
    _isPicStatus = YES;
    [self resetFrame];
}

-(BOOL)ifDisableSendBtn
{
    NSInteger optionNum = self.optionArray.count;
    NSInteger optionViewNum = self.optionViewArray.count;
    NSInteger optionImageNum = self.imageArray.count;
    
    if (_isPicStatus)
    {
         if (optionNum > 0 && optionViewNum > 0 && optionImageNum > 0 && optionNum == optionViewNum && optionImageNum == optionViewNum)
         {
             return NO;
         }
        else
        {
            return YES;
        }
    }
    else
    {
        if (optionNum > 0 && optionViewNum > 0 && optionNum == optionViewNum)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}



-(NSMutableArray *)optionArray
{
    _optionArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < _optionViewArray.count; i++)
    {
        WLVoteSingleView *voteSingleView = _optionViewArray[i];
        
        if ([voteSingleView inputStr].length > 0)
        {
             [_optionArray addObject:[voteSingleView inputStr]];
        }
    }
    
    return _optionArray;
}

-(NSMutableArray *)imageArray
{
    _imageArray = [[NSMutableArray alloc] initWithCapacity:0];
   
    if (_isPicStatus)
    {
        for (int i = 0; i < _optionViewArray.count; i++)
        {
            WLVoteSingleView *voteSingleView = _optionViewArray[i];
            
            if (voteSingleView.assetModel)
            {
                [_imageArray addObject:[voteSingleView assetModel]];
            }
        }
    }
    
    return _imageArray;
}



#pragma mark - Action
-(void)deleteOption:(WLVoteSingleView *)view
{
   NSInteger indexNum = [_optionViewArray indexOfObject:view];
    if  (indexNum != NSNotFound) {
        
        [view removeFromSuperview];
        
        [_optionViewArray removeObjectAtIndex:indexNum];
        [_imageArray removeAllObjects];
        
        //如果都没图片,则修改状态
        BOOL havePic = NO;
         for (int i = 0; i < _optionViewArray.count; i++)
         {
             WLVoteSingleView *voteSingleView = _optionViewArray[i];
             if (voteSingleView.assetModel)
             {
                 havePic = YES;
             }
         }
        
        _isPicStatus = havePic;
      
        
        //重新布局
        [self resetFrame];
        [self resetPlaceHolder];
    }
    
    
    //置为不可用
    if (_optionViewArray.count == 2)
    {
        for (int i = 0; i < _optionViewArray.count; i++)
        {
            WLVoteSingleView *voteSingleView = _optionViewArray[i];
            voteSingleView.deleteBtnEnable = NO;
        }
    }
    
      if (_optionViewArray.count < 4)
      {
          addBtn.hidden = NO;
      }
    
        [self inputNum:nil];
}

-(void)addBtnPressed:(id)sender
{
    CGFloat currentHeight = 0;
    
    [self.superview endEditing:YES];
    [self endEditing:YES];
    
    if (_optionViewArray.count != 4)
    {
        addBtn.hidden = NO;
        
        if (_isPicStatus == YES)
        {
            WLVoteSingleView *firstRowOfVoteSingleView = _optionViewArray[0];
            
            CGFloat x = _optionViewArray.count%2 ==1?15:firstRowOfVoteSingleView.left + 8;
            
            WLVoteSingleView *voteSingleView = [[WLVoteSingleView alloc] initWithFrame:CGRectMake(x,firstRowOfVoteSingleView.bottom, firstRowOfVoteSingleView.width, firstRowOfVoteSingleView.height)];
            voteSingleView.placeHolderStr = [NSString stringWithFormat:[AppContext getStringForKey:@"option_num" fileName:@"publish"],_optionViewArray.count + 1];
            voteSingleView.deleteBtnEnable = YES;
            voteSingleView.delegate = self;
            voteSingleView.type = 1;
            [self addSubview:voteSingleView];
            [_optionViewArray addObject:voteSingleView];
            
            NSInteger lineNum = (_optionViewArray.count/2 + 1);
            currentHeight = (((kScreenWidth - 8 - 30)/2.0)*0.75 + 48 + 5)*lineNum + 32 + 160;
            [self setIsPicStatus:YES];
        }
        else
        {
            WLVoteSingleView *voteSingleView = [[WLVoteSingleView alloc] initWithFrame:CGRectMake(15,_optionViewArray.count*48, kScreenWidth, 48)];
            voteSingleView.placeHolderStr = [NSString stringWithFormat:[AppContext getStringForKey:@"option_num" fileName:@"publish"],_optionViewArray.count + 1];
            voteSingleView.deleteBtnEnable = YES;
            voteSingleView.delegate = self;
            voteSingleView.type = 0;
            [self addSubview:voteSingleView];
            [_optionViewArray addObject:voteSingleView];
            
            currentHeight = 48*_optionViewArray.count + 32 + 160;
            
            [self setIsPicStatus:NO];
        }
    }
    
    self.height = currentHeight;
    
    for (int i = 0; i < _optionViewArray.count; i++)
    {
        WLVoteSingleView *voteSingleView = _optionViewArray[i];
        voteSingleView.deleteBtnEnable = YES;
    }
    
    [self resetPlaceHolder];
    
    
    if (_optionViewArray.count == 4)
    {
        addBtn.hidden = YES;
    }
    
    
    if ([_delegate respondsToSelector:@selector(addOption:)])
    {
         [_delegate addOption:currentHeight];
    }
    
    
}



#pragma mark - LMJDropdownMenuDelegate
- (void)dropdownMenu:(LMJDropdownMenu *)menu selectedCellNumber:(NSInteger)number
{
    //NSLog(@"选择了第%d个",number);
    switch (number) {
        case 0:
            _time = 24*3600;
            break;
        case 1:
            _time = 72*3600;
            break;
        case 2:
            _time = 24*7*3600;
            break;
        case 3:
            _time = 24*30*3600;
            break;
        case 4:
            _time = -1;
            break;
            
        default:
            _time = 72*3600;
            break;
    }
}

- (void)dropdownMenuWillShow:(LMJDropdownMenu *)menu    // 当下拉菜单将要显示时调用
{
    [self endEditing:YES];
    [self.superview endEditing:YES];
    //隐藏add topic
    if ([_delegate respondsToSelector:@selector(tapMenu)])
    {
        [_delegate tapMenu];
    }
}
- (void)dropdownMenuDidShow:(LMJDropdownMenu *)menu   // 当下拉菜单已经显示时调用
{
  
}
- (void)dropdownMenuWillHidden:(LMJDropdownMenu *)menu  // 当下拉菜单将要收起时调用
{
    [self endEditing:YES];
    [self.superview endEditing:YES];
  
}
- (void)dropdownMenuDidHidden:(LMJDropdownMenu *)menu
{
    if ([_delegate respondsToSelector:@selector(foldMenu)])
    {
        [_delegate foldMenu];
    }
}

//重置布局
-(void)resetFrame
{
    if (_isPicStatus == YES)
    {
        for (int i = 0; i < _optionViewArray.count; i++)
        {
            CGFloat x = (i%2 ==0?15:15+(kScreenWidth - 8 - 30)/2.0 + 8);
            CGFloat y = (i/2 == 1?((kScreenWidth - 8 - 30)/2.0)*0.75 + 48 + 5 :0);
            
            WLVoteSingleView *voteSingleView = _optionViewArray[i];
            [voteSingleView setType:1];
            voteSingleView.frame = CGRectMake(x, y, (kScreenWidth - 8 - 30)/2.0, ((kScreenWidth - 8 - 30)/2.0)*0.75 + 48 + 5);
        }
        
        timeLabel.frame = CGRectMake(15, _optionViewArray.count==2? (((kScreenWidth - 8 - 30)/2.0)*0.75 + 48 + 5):(((kScreenWidth - 8 - 30)/2.0)*0.75 + 48+ 5)*2, timeLabel.width, 32);
        [dropdownMenu setFrame:CGRectMake(timeLabel.right + 5, timeLabel.top, 170, 32)];
    }
    else
    {
        for (int i = 0; i < _optionViewArray.count; i++)
        {
            WLVoteSingleView *voteSingleView = _optionViewArray[i];
            [voteSingleView setType:0];
            voteSingleView.frame = CGRectMake(15, 48*i, kScreenWidth, 48);
        }
        
        timeLabel.frame = CGRectMake(15, 48*_optionViewArray.count, timeLabel.width, 32);
        [dropdownMenu setFrame:CGRectMake(timeLabel.right + 5,  timeLabel.top, 170, 32)];
    }
    
    self.height = dropdownMenu.bottom + 160;
    
    if ([_delegate respondsToSelector:@selector(addOption:)])
    {
        [_delegate addOption:self.height];
    }
    
    [dropdownMenu resetFrame];
    addBtn.frame = CGRectMake(kScreenWidth - 34 - 10, timeLabel.top, 34, 30);
    
    NSLog(@"=============%f",dropdownMenu.bottom);
}

//重置placeholder
-(void)resetPlaceHolder
{
    for (int i = 0; i < _optionViewArray.count; i++)
    {
        WLVoteSingleView *voteSingleView = _optionViewArray[i];
        voteSingleView.placeHolderStr = [NSString stringWithFormat:[AppContext getStringForKey:@"option_num" fileName:@"publish"],i + 1];
    }
}


#pragma mark - WLVoteSingleViewDelegate

-(void)inputNum:(WLVoteSingleView *)view
{
    //检测是否选项都写满了,写满了才可以显示send按钮
    for (int i = 0; i < _optionViewArray.count; i++)
    {
        WLVoteSingleView *voteSingleView = _optionViewArray[i];
        
        if (voteSingleView.inputStr.length > 0)
        {
            _isALLFieldFill = YES;
        }
        else
        {
            _isALLFieldFill = NO;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(allOptionHasbeenFill:)])
    {
        [_delegate allOptionHasbeenFill:_isALLFieldFill];
    }
}

-(void)addImage:(WLVoteSingleView *)view
{
    NSInteger indexNum = [_optionViewArray indexOfObject:view];
    
    if ([self.delegate respondsToSelector:@selector(openAlbum:)])
    {
        [_delegate openAlbum:indexNum];
        currentVoteIndex = indexNum;
    }
}

#pragma mark - WLVoteSingleViewDelegate
-(void)optionTextViewIsBeginEdit:(WLVoteSingleView *)view
{
    if ([self.delegate respondsToSelector:@selector(optionBeginToInput)])
    {
        [_delegate optionBeginToInput];
    }
}

-(void)optionTextViewIsEndEdit:(WLVoteSingleView *)view
{
    if ([self.delegate respondsToSelector:@selector(optionEndInput)])
    {
        [_delegate optionEndInput];
    }
}


@end
