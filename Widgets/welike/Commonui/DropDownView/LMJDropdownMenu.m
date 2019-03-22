//
//  LMJDropdownMenu.m
//
//  Version:1.0.0
//
//  Created by MajorLi on 15/5/4.
//  Copyright (c) 2015年 iOS开发者公会. All rights reserved.
//

#import "LMJDropdownMenu.h"


#define VIEW_CENTER(aView)       ((aView).center)
#define VIEW_CENTER_X(aView)     ((aView).center.x)
#define VIEW_CENTER_Y(aView)     ((aView).center.y)

#define FRAME_ORIGIN(aFrame)     ((aFrame).origin)
#define FRAME_X(aFrame)          ((aFrame).origin.x)
#define FRAME_Y(aFrame)          ((aFrame).origin.y)

#define FRAME_SIZE(aFrame)       ((aFrame).size)
#define FRAME_HEIGHT(aFrame)     ((aFrame).size.height)
#define FRAME_WIDTH(aFrame)      ((aFrame).size.width)



#define VIEW_BOUNDS(aView)       ((aView).bounds)

#define VIEW_FRAME(aView)        ((aView).frame)

#define VIEW_ORIGIN(aView)       ((aView).frame.origin)
#define VIEW_X(aView)            ((aView).frame.origin.x)
#define VIEW_Y(aView)            ((aView).frame.origin.y)

#define VIEW_SIZE(aView)         ((aView).frame.size)
#define VIEW_HEIGHT(aView)       ((aView).frame.size.height)
#define VIEW_WIDTH(aView)        ((aView).frame.size.width)


#define VIEW_X_Right(aView)      ((aView).frame.origin.x + (aView).frame.size.width)
#define VIEW_Y_Bottom(aView)     ((aView).frame.origin.y + (aView).frame.size.height)






#define AnimateTime 0.25f   // 下拉动画时间



@implementation LMJDropdownMenu
{
    UIImageView * _arrowMark;   // 尖头图标
    UIView      * _listView;    // 下拉列表背景View
    UITableView * _tableView;   // 下拉列表
    
    NSArray     * _titleArr;    // 选项数组
    CGFloat       _rowHeight;   // 下拉列表行高
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createMainBtnWithFrame:frame];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];

    [self createMainBtnWithFrame:frame];
}


- (void)createMainBtnWithFrame:(CGRect)frame{
    
//    [_mainBtn removeFromSuperview];
//    _mainBtn = nil;
    
    // 主按钮 显示在界面上的点击按钮
    // 样式可以自定义
    
    if (!_mainBtn)
    {
        _mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mainBtn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_mainBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        [_mainBtn setTitle:[AppContext getStringForKey:@"three_day" fileName:@"publish"] forState:UIControlStateNormal];
        [_mainBtn addTarget:self action:@selector(clickMainBtn:) forControlEvents:UIControlEventTouchUpInside];
        _mainBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _mainBtn.titleLabel.font    = kRegularFont(14);
        _mainBtn.titleEdgeInsets    = UIEdgeInsetsMake(0, 8, 0, 0);
        _mainBtn.selected           = NO;
        _mainBtn.backgroundColor    = [UIColor whiteColor];
        _mainBtn.layer.borderColor  = kNavShadowColor.CGColor;
        _mainBtn.layer.borderWidth  = 1;
        _mainBtn.layer.cornerRadius = 3;
        
        [self addSubview:_mainBtn];
    }
    else
    {
        [_mainBtn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
    
    if (!_arrowMark)
    {
        _arrowMark = [[UIImageView alloc] initWithFrame:CGRectMake(_mainBtn.frame.size.width - 15, 0, 8, 6)];
        _arrowMark.center = CGPointMake(VIEW_CENTER_X(_arrowMark), VIEW_HEIGHT(_mainBtn)/2);
        _arrowMark.image  = [AppContext getImageForKey:@"post_dropdown"];
        [_mainBtn addSubview:_arrowMark];
    }
    else
    {
        _arrowMark.frame = CGRectMake(_mainBtn.frame.size.width - 15, 0, 8, 6);
        _arrowMark.center = CGPointMake(VIEW_CENTER_X(_arrowMark), VIEW_HEIGHT(_mainBtn)/2);
        _arrowMark.image  = [AppContext getImageForKey:@"post_dropdown"];
    }

}


- (void)setMenuTitles:(NSArray *)titlesArr rowHeight:(CGFloat)rowHeight{
    
    if (self == nil) {
        return;
    }
    
    _titleArr  = [NSArray arrayWithArray:titlesArr];
    _rowHeight = rowHeight;
    
    _mainBtn.selected = NO;
    _arrowMark.transform = CGAffineTransformIdentity;
    
    // 下拉列表背景View
    if (!_listView)
    {
        _listView = [[UIView alloc] init];
        _listView.clipsToBounds       = YES;
        _listView.layer.masksToBounds = NO;
        _listView.layer.borderColor   = kNavShadowColor.CGColor;
        _listView.layer.borderWidth   = 1.0;
        _listView.layer.cornerRadius = 3;
    }
//    _listView.backgroundColor = [UIColor redColor];
    _listView.frame = CGRectMake(VIEW_X(self) , VIEW_Y_Bottom(self) - 1, VIEW_WIDTH(self),  0);

    
    // 下拉列表TableView
    if (!_tableView)
    {
         _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView))];
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.bounces         = NO;
        [_listView addSubview:_tableView];
    }
    
    _tableView.frame = CGRectMake(0, 0,VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidHidden:)]) {
        [self.delegate dropdownMenuDidHidden:self]; // 已经隐藏回调代理
    }
}

- (void)resetFrame
{
    [self setMenuTitles:_titleArr rowHeight:_rowHeight];
}


- (void)clickMainBtn:(UIButton *)button{
    
    [self.superview addSubview:_listView]; // 将下拉视图添加到控件的俯视图上
    
    if(button.selected == NO) {
        [self showDropDown];
    }
    else {
        [self hideDropDown];
    }
}

- (void)showDropDown{   // 显示下拉列表
    
    [_listView.superview bringSubviewToFront:_listView]; // 将下拉列表置于最上层
    
    
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenuWillShow:)]) {
        [self.delegate dropdownMenuWillShow:self]; // 将要显示回调代理
    }
    
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
        self->_arrowMark.transform = CGAffineTransformMakeRotation(M_PI);
        self->_listView.frame  = CGRectMake(VIEW_X(self->_listView), VIEW_Y(self->_listView), VIEW_WIDTH(self->_listView), self->_rowHeight *self->_titleArr.count);
        self->_tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(self->_listView), VIEW_HEIGHT(self->_listView));
        
    }completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(dropdownMenuDidShow:)]) {
            [self.delegate dropdownMenuDidShow:self]; // 已经显示回调代理
        }
    }];
    
    
    
    _mainBtn.selected = YES;
}
- (void)hideDropDown{  // 隐藏下拉列表
    
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenuWillHidden:)]) {
        [self.delegate dropdownMenuWillHidden:self]; // 将要隐藏回调代理
    }
    
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
        self->_arrowMark.transform = CGAffineTransformIdentity;
        self->_listView.frame  = CGRectMake(VIEW_X(self->_listView), VIEW_Y(self->_listView), VIEW_WIDTH(self->_listView), 0);
        self->_tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(self->_listView), VIEW_HEIGHT(self->_listView));
        
    }completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(dropdownMenuDidHidden:)]) {
            [self.delegate dropdownMenuDidHidden:self]; // 已经隐藏回调代理
        }
    }];
    
    
    
    _mainBtn.selected = NO;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //---------------------------下拉选项样式，可在此处自定义-------------------------
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font          = kRegularFont(14);
        cell.textLabel.textColor     = kBodyFontColor;
        cell.selectionStyle          = UITableViewCellSelectionStyleNone;
        
//        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, _rowHeight -0.5, VIEW_WIDTH(cell), 0.5)];
//        line.backgroundColor = [UIColor blackColor];
//        [cell addSubview:line];
        //---------------------------------------------------------------------------
    }
    
    cell.textLabel.text =[_titleArr objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [_mainBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:selectedCellNumber:)]) {
        [self.delegate dropdownMenu:self selectedCellNumber:indexPath.row]; // 回调代理
    }
    
    [self hideDropDown];
}
@end
