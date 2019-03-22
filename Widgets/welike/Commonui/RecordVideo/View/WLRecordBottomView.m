//
//  WLRecordBottomView.m
//  welike
//
//  Created by gyb on 2019/1/7.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLRecordBottomView.h"
#import "WLRecordControlView.h"
#import "QUProgressView.h"

@implementation WLRecordBottomView

#pragma mark - UI
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      
        CGFloat width = (kScreenWidth - 72 - 32)/4;
        
        deleteButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setImage:[AppContext getImageForKey:@"record_delete"] forState:UIControlStateNormal];
        deleteButton.frame = CGRectMake(8, (frame.size.height - width)/2.0, width, width);
        [self addSubview:deleteButton];
        
        finishRecordBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        [finishRecordBtn addTarget:self action:@selector(finishBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [finishRecordBtn setImage:[AppContext getImageForKey:@"record_finish"] forState:UIControlStateNormal];
        finishRecordBtn.frame = CGRectMake(kScreenWidth - 8 - width, (frame.size.height - width)/2.0, width, width);
        [self addSubview:finishRecordBtn];
        
        recordBtn =  [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 72)/2.0, (frame.size.height - 72)/2.0, 72, 72)];
        [recordBtn setImage:[AppContext getImageForKey:@"camera_recorder"] forState:UIControlStateNormal];
        [recordBtn addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [recordBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [recordBtn addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchDragOutside];
        [self addSubview:recordBtn];
        
        progressView = [[QUProgressView alloc] initWithFrame: CGRectMake(0,  frame.size.height - 5, kScreenWidth, 5)];
        progressView.showBlink = NO;
        progressView.showNoticePoint = YES;
        progressView.maxDuration = 1;
        progressView.minDuration = 0;
        progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        [self addSubview:progressView];
        
    }
    return self;
}


-(void)recordButtonTouchUp
{
    WLRecordControlView *controlView = (WLRecordControlView *)[self superview];
    if ([controlView tapRecordBtnUp])
    {
        controlView.tapRecordBtnUp();
    }
}

-(void)recordButtonTouchDown
{
    WLRecordControlView *controlView = (WLRecordControlView *)[self superview];
    if ([controlView tapRecordBtnDown])
    {
        controlView.tapRecordBtnDown();
    }
}

-(void)deleteButtonPressed
{
    
}

-(void)finishBtnPressed
{
      WLRecordControlView *controlView = (WLRecordControlView *)[self superview];
    if ([controlView tapFinishBtnDown])
    {
        controlView.tapFinishBtnDown();
    }
}



@end
