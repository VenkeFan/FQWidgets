//
//  ThumbGridView.m
//  CuctvWeibo
//
//  Created by GYB on 14-6-4.
//
//

#import "WLThumbGridView.h"
#import "WLImageHelper.h"
#import "WLAssetModel.h"

@implementation WLThumbGridView


-(void)dealloc
{
  

}

- (id)initWithFrame:(CGRect)frame withTarget:(id)_target
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIButton *addbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addbtn.frame = CGRectZero;//CGRectMake(15, 0, (Screen_width - 38)/3.0, (Screen_width - 38)/3.0);
        addbtn.backgroundColor = videoThumbBg;
        addbtn.layer.borderColor = kBorderLineColor.CGColor;
        addbtn.layer.borderWidth = 1;
        [addbtn setImage:[AppContext getImageForKey:@"publish_add_image"]  forState:UIControlStateNormal];
        addbtn.tag = 9;
        [addbtn addTarget:self action:@selector(addImageBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addbtn];
       
        for (int i = 0; i < 9; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.contentMode = UIViewContentModeScaleAspectFill;
            btn.tag = i + 10;
            btn.layer.borderColor = kBorderLineColor.CGColor;
            btn.layer.borderWidth = 1;
            [self addSubview:btn];
            btn.frame = CGRectZero;

            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            //closeBtn.backgroundColor = [UIColor redColor];
            closeBtn.frame = CGRectZero;
            [closeBtn setImage: [AppContext getImageForKey:@"publish_gridPic_delete"] forState:UIControlStateNormal];
            closeBtn.imageEdgeInsets = UIEdgeInsetsMake(closeBtn.imageEdgeInsets.top-3, closeBtn.imageEdgeInsets.left + 3, closeBtn.imageEdgeInsets.bottom+3, closeBtn.imageEdgeInsets.right-3);
            [closeBtn addTarget:self action:@selector(closeCurrentPic:) forControlEvents:UIControlEventTouchUpInside];
            closeBtn.showsTouchWhenHighlighted = YES;
            closeBtn.tag = i + 20;
            [btn addSubview:closeBtn];
            closeBtn.hidden = YES;
        }
    }
    return self;
}

//更新用
-(void)setImageArray:(NSMutableArray *)array
{
    _imageArray = array;
    
    if (_imageArray.count == 0)
    {
        self.height = 0;
    }
    else
    if (_imageArray.count/3 == 3)
    {
        self.height = kScreenWidth - 30;
    }
    else
    {
        self.height = ((kScreenWidth - 40)/3.0)*(_imageArray.count/3 + 1) + (_imageArray.count/3)*5;
    }
    
    //在这里改变添加按钮的位置
    UIButton *addBtn = (UIButton*)[self viewWithTag:9];
    
    if (_imageArray.count == 9 || _imageArray.count == 0)
    {
        addBtn.frame = CGRectZero;
    }
    else
    {
        //计算行数
        NSInteger rowNum = _imageArray.count/3;//3
        
        //计算列数
        NSInteger lineNum = _imageArray.count%3;//0
        
        addBtn.frame = CGRectMake(lineNum*(kScreenWidth - 40)/3.0 + lineNum*5, rowNum* (kScreenWidth - 40)/3.0 + rowNum*5,  (kScreenWidth - 40)/3.0,  (kScreenWidth - 40)/3.0);
    }
    
    for (int i = 0; i < 9; i++)
    {
        UIButton *btn = (UIButton*)[self viewWithTag:i+10];
        btn.frame = CGRectZero;

        
        UIButton *closeBtn = (UIButton*)[self viewWithTag:i+20];
        closeBtn.hidden = YES;
        closeBtn.frame = CGRectZero;
    }

    //每行显示个数
    for (int i = 0; i < _imageArray.count; i++)
    {
        WLAssetModel *assetModel = [_imageArray objectAtIndex:i];
        PHAsset *asset = [assetModel asset];
        

        UIButton *btn = (UIButton*)[self viewWithTag:i+10];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        btn.frame = CGRectMake((i%3)*5 + (i%3)*(kScreenWidth - 40)/3.0, (i/3)*((kScreenWidth - 40)/3.0+5), (kScreenWidth - 40)/3.0, (kScreenWidth - 40)/3.0);
        [btn addTarget:self action:@selector(browseSelctImage:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *closeBtn = (UIButton*)[self viewWithTag:i+20];
        closeBtn.frame = CGRectMake(btn.frame.size.width - 30, 0, 30, 30);
        closeBtn.hidden = NO;
        
        [WLImageHelper imageFromAsset:asset size:CGSizeMake(btn.width*6, btn.height*6) result:^(UIImage *thumbImage) {
            [btn setImage:thumbImage forState:UIControlStateNormal];
        }];
        
    }
}

-(void)browseSelctImage:(id)sender
{
    UIButton *closeBtn = (UIButton*)sender;
    NSInteger tag = closeBtn.tag - 10;
    
    [_delegate browseThumbAtIndex:tag];
}

-(void)addImageBtnPressed:(id)sender
{
    [_delegate addPhoto];
}




-(void)closeCurrentPic:(id)sender
{
    UIButton *closeBtn = (UIButton*)sender;
    NSInteger tag = closeBtn.tag - 20;
    
    [_imageArray removeObjectAtIndex:tag];
    
    [_delegate removeThumbAtIndex:tag];
    
    [self setImageArray:_imageArray];
}

@end
