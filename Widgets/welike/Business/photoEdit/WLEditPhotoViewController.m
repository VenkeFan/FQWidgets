//
//  EditPhotoViewController.m
//  CuctvWeibo
//
//  Created by cuctv-gyb on 17/2/22.
//
//

#import "WLEditPhotoViewController.h"
#import "WLEditSinglePhotoView.h"
#import "WLEditPhotoCollectionViewCell.h"
#import "WLAssetModel.h"

@interface WLEditPhotoViewController ()

@property (strong, nonatomic) WLEditSinglePhotoView *singlePhotoView;


@property (strong, nonatomic) UIBarButtonItem *leftItem;
@property (strong, nonatomic) UIButton *rightButton;


@property (strong, nonatomic) NSMutableArray *modifyPhotoArray;

@property (assign, nonatomic) int pageNum;
@property (assign, nonatomic) BOOL isEditGif;

@end

@implementation WLEditPhotoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationBar setTitle:@"Cut"];
    self.navigationBar.leftBtn.hidden = NO;
    self.navigationBar.rightBtn.hidden = NO;
   
    [self.navigationBar setLeftBtnImageName:@"common_nav_close"];
    [self.navigationBar setRightBtnImageName:@"nickname_check_ok"];
    
    [self buildUI];
}

- (void)buildUI
{
  //  self.view.backgroundColor = kcolor (227, 227, 227);

    [self initBottomToolBar];
  //  [self cutPhotoControl];
}


- (void)initBottomToolBar{
   
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    if (_edit_photo_type == Edit_photo_type_poll)
    {
        _singlePhotoView = [[WLEditSinglePhotoView alloc] initWithFrame:CGRectMake(0, kNavBarHeight + (kScreenHeight - kScreenWidth*0.75 - kNavBarHeight - kTabBarHeight)/2.0, kScreenWidth, kScreenWidth*0.75) collectionViewLayout:flowLayout];
        [self.view addSubview:_singlePhotoView];
    }
    
    if (_edit_photo_type == Edit_photo_type_status)
    {
        _singlePhotoView = [[WLEditSinglePhotoView alloc] initWithFrame:CGRectMake(0, kNavBarHeight + (kScreenHeight - kScreenWidth*1 - kNavBarHeight - kTabBarHeight)/2.0, kScreenWidth, kScreenWidth*1) collectionViewLayout:flowLayout];
        [self.view addSubview:_singlePhotoView];
    }
    
    
//    __weak typeof(self) weakSelf = self;
//    _singlePhotoView.pageNumBlock = ^(int pageNum){
//        weakSelf.pageNum = pageNum;
//        if (weakSelf.photoArray.count == 1) {
//            weakSelf.navigationItem.title = nil;
//
//        }else{
//
//            weakSelf.navigationItem.title = [NSString stringWithFormat:@"%tu/%tu",pageNum + 1,weakSelf.photoArray.count];
//        }
//
//    };
    
    bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kTabBarHeight, kScreenWidth, 60)];
//    bottomToolBar.backgroundColor = RGBCOLOR(235, 235, 235);
    [self.view addSubview:bottomToolBar];
    
//    cutPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    cutPhotoBtn.frame = CGRectMake((kScreenWidth/2.0 - 56)/2.0, 0, 44, 44);
//    [cutPhotoBtn setImage:[AppContext getImageForKey:@"cut_Photo"] forState:UIControlStateNormal];
//    [cutPhotoBtn addTarget:self action:@selector(cutPhotoClick) forControlEvents:UIControlEventTouchUpInside];
//    [bottomToolBar addSubview:cutPhotoBtn];
    
    rotatePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rotatePhotoBtn.frame = CGRectMake((kScreenWidth - 44)/2.0, 0, 44, 44);
    [rotatePhotoBtn setImage:[AppContext getImageForKey:@"rotatePhoto"] forState:UIControlStateNormal];
    [rotatePhotoBtn addTarget:self action:@selector(rotatePhotoClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBar addSubview:rotatePhotoBtn];

}

- (void)cutPhotoClick {
    WLAssetModel *assetModel = self.photoArray[[self currentCellIndex]];
    PHAsset *asset = assetModel.asset;
    if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]  && !self.isEditGif) {
        self.isEditGif = YES;
        [self cutPhotoEvent];
    }else{
        [self cutPhotoEvent];
    }
}

- (void)rotatePhotoClick {
    WLAssetModel *assetModel = self.photoArray[[self currentCellIndex]];
    PHAsset *asset = assetModel.asset;
    if ([[asset valueForKey:@"filename"]hasSuffix:@"GIF"]  && !self.isEditGif) {
        [self rotatePhotoEvent];
    }else{
        [self rotatePhotoEvent];
    }
}


- (void)cutPhotoEvent {
    
    bottomToolBar.hidden = YES;
    cutToolBar.hidden = NO;
    
    self.navigationBar.leftBtn.hidden = YES;
    self.navigationBar.rightBtn.hidden = YES;

    WLEditPhotoCollectionViewCell *cell = self.singlePhotoView.visibleCells.firstObject;
    [cell adjustCutPhotoState];
 
    self.singlePhotoView.scrollEnabled = NO;
}

- (void)cutPhotoControl{

    cutToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, _singlePhotoView.bottom + 20, kScreenWidth, 60)];
    //    bottomToolBar.backgroundColor = RGBCOLOR(235, 235, 235);
    [self.view addSubview:cutToolBar];
    cutToolBar.hidden = YES;
    
    UIButton *cutCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cutCancelBtn.frame = CGRectMake((kScreenWidth/2.0 - 56)/2.0, 0, 44, 44);
    [cutCancelBtn setImage:[AppContext getImageForKey:@"common_nav_close"] forState:UIControlStateNormal];
    [cutCancelBtn addTarget:self action:@selector(cancelCutBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [cutToolBar addSubview:cutCancelBtn];
    
    UIButton *cutConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cutConfirmBtn.frame = CGRectMake((kScreenWidth/2.0 - 56)/2.0 + kScreenWidth/2.0, 0, 44, 44);
    [cutConfirmBtn setImage:[AppContext getImageForKey:@"nickname_check_ok"] forState:UIControlStateNormal];
    [cutConfirmBtn addTarget:self action:@selector(doneCutBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [cutToolBar addSubview:cutConfirmBtn];
}


- (void)cancelCutBtnClick {
    
    bottomToolBar.hidden = NO;
    cutToolBar.hidden = YES;
    
    self.navigationBar.leftBtn.hidden = NO;
    self.navigationBar.rightBtn.hidden = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)self.pageNum inSection:0];

    WLEditPhotoCollectionViewCell *cell = (WLEditPhotoCollectionViewCell *)[self.singlePhotoView cellForItemAtIndexPath:indexPath];
    [cell adjustOriginPhotoState];
    bottomToolBar.alpha = 1;
    if (self.photoArray.count == 1) {
        self.navigationItem.title = nil;

    }else{

        self.navigationItem.title = [NSString stringWithFormat:@"%tu/%tu",self.pageNum + 1,self.photoArray.count];
    }
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    rotatePhotoBtn.hidden = NO;
    cutPhotoBtn.hidden = NO;
    self.singlePhotoView.scrollEnabled = YES;
}


- (void)doneCutBtnClick {

    WLEditPhotoCollectionViewCell *cell = self.singlePhotoView.visibleCells.firstObject;
    [cell cropImage];
//    [self.singlePhotoView reloadData];
    cell = self.singlePhotoView.visibleCells.firstObject;

    [self cancelCutBtnClick];
}

- (void)rotatePhotoEvent {

    WLEditPhotoCollectionViewCell *cell = self.singlePhotoView.visibleCells.firstObject;
    [cell photoRotate];
//    [self.singlePhotoView reloadData];
}

- (NSInteger)currentCellIndex {
    WLEditPhotoCollectionViewCell *cell = self.singlePhotoView.visibleCells.firstObject;
    NSIndexPath *indexPath = [self.singlePhotoView indexPathForCell:cell];
    return indexPath.row;
}


#pragma mark - Lazy Load
- (void)setPhotoArray:(NSMutableArray *)photoArray {
    _photoArray = photoArray;


//    NSLog(@"%@------%@",photoArray,self.modifyPhotoArray);
    self.singlePhotoView.photoArray = photoArray;
}

-(void)setSignalImage:(UIImage *)signalImage
{
    _signalImage = signalImage;
    self.singlePhotoView.signalImage = signalImage;
}


//- (void)navigationBarLeftBtnDidClicked
//{
//
//}


-(void)navigationBarRightBtnDidClicked
{
    //在这里对选择的图片区域进行裁剪,并保存上传
    
    WLEditPhotoCollectionViewCell *cell = self.singlePhotoView.visibleCells.firstObject;

    [cell saveAndFinish:^(WLAssetModel *asset) {
       
        
        if ([self.photoArray containsObject:asset])
        {
            if (self.photoArrayBlock) {
                self.photoArrayBlock(self.photoArray);
            }
        }
        else
        {
            if (self.photoArray)
            {
                [self.photoArray removeAllObjects];
                [self.photoArray addObject:asset];
            }
            else
            {
                self.photoArray = [[NSMutableArray alloc] initWithCapacity:0];
                [self.photoArray addObject:asset];
            }

            if (self.photoArrayBlock) {
                self.photoArrayBlock(self.photoArray);
            }

        }

        [self dismissViewControllerAnimated:YES completion:^{

        }];

        
    }];
}


//- (void)setClickIndex:(NSInteger)clickIndex {
//    _clickIndex = clickIndex;
//
//    self.singlePhotoView.contentOffset = CGPointMake(self.clickIndex * kScreenWidth, 0);
//}
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return UIInterfaceOrientationPortrait;
//}
//
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}
@end
