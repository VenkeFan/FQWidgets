//
//  WLSelectStatusBgView.m
//  welike
//
//  Created by gyb on 2018/11/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLSelectStatusBgView.h"
#import "WLStatusEditCell.h"
#import "WLStatusInfo.h"
#import "WLStatusSelectBgCell.h"

@interface WLSelectStatusBgView ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation WLSelectStatusBgView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        
        self.separatorColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = 68;
        self.pagingEnabled = NO;
    }
    return self;
}

-(void)setStatusInfo:(WLStatusInfo *)statusInfo
{
    _statusInfo = statusInfo;
   
    if (_statusInfo.picUrlList.count == 0)
    {
        return;
    }
    
    [self reloadData];
    
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//自定义的图片选择
-(void)changeCustomImage:(UIImage *)image
{
    
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_statusInfo picUrlList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WLStatusSelectBgCell";
    WLStatusSelectBgCell *cell = (WLStatusSelectBgCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[WLStatusSelectBgCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    
    cell.picUrlStr = _statusInfo.picUrlList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.SelectStatusBgDelegate respondsToSelector:@selector(changeBg:)])
    {
        [self.SelectStatusBgDelegate changeBg:indexPath.row];
    }
}

#pragma mark ScrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.superview endEditing:YES];
    
}


@end
