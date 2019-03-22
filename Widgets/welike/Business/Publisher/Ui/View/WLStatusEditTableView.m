//
//  WLStatusEditTableView.m
//  welike
//
//  Created by gyb on 2018/11/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLStatusEditTableView.h"
#import "WLStatusEditCell.h"
#import "WLStatusInfo.h"

@interface WLStatusEditTableView ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation WLStatusEditTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        
        self.separatorColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = kScreenWidth;
        self.pagingEnabled = YES;
     
//        inputView = [[UITextView alloc] initWithFrame:CGRectMake(25, 48, kScreenWidth - 50, kScreenWidth - 96)];
//        inputView.textAlignment = NSTextAlignmentCenter;
//        inputView.layer.borderWidth = 4;
//        inputView.layer.borderColor = [UIColor redColor].CGColor;
//        //inputView.backgroundColor = [UIColor redColor];
//        //        inputView.font =
//        [self.superview addSubview:inputView];
    }
    return self;
}

-(void)setStatusInfo:(WLStatusInfo *)statusInfo
{
    _statusInfo = statusInfo;
    [self reloadData];
    
}

-(void)changeCustomImage:(UIImage *)image
{
    //当前cell
    NSArray *cells = [self visibleCells];
    
    if (cells.count > 0)
    {
        WLStatusEditCell *cell = cells.firstObject;
        
        [cell changeBg:image];
    }
}


-(void)changeToIndex:(NSInteger)index
{
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

-(NSString *)currentPicUrl
{
    NSArray *cells = [self visibleCells];
    
    if (cells.count > 0)
    {
        WLStatusEditCell *cell = cells.firstObject;
        
        return cell.picUrlStr;
    }
    else
    {
        return nil;
    }
}

-(WLStatusEditCell *)currentCell
{
    NSArray *cells = [self visibleCells];
    
    if (cells.count > 0)
    {
        WLStatusEditCell *cell = cells.firstObject;
        
        return cell;
    }
    else
    {
        return nil;
    }
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_statusInfo picUrlList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WLStatusEditCell";
    WLStatusEditCell *cell = (WLStatusEditCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[WLStatusEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    
    cell.picUrlStr = _statusInfo.picUrlList[indexPath.row];
    return cell;
}




#pragma mark ScrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.superview endEditing:YES];
    
    if ([self.editDelegate respondsToSelector:@selector(endEdit)])
    {
        [self.editDelegate endEdit];
    }
}

@end
