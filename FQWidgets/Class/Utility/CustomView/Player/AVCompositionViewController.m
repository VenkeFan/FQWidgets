//
//  AVCompositionViewController.m
//  FQWidgets
//
//  Created by fanqi on 2019/5/1.
//  Copyright © 2019年 fan qi. All rights reserved.
//

#import "AVCompositionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "FQVideoComposition.h"

static NSString *reusCellID = @"reusCellID";

@interface AVCompositionViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    AVAsset *_asset1;
    AVAsset *_asset2;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation AVCompositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.textColor = kBodyFontColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FQVideoComposition *composition = [FQVideoComposition new];
    if (indexPath.row == 0) {
        if (!_asset1 || !_asset2) {
            UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
            ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            ctr.delegate = self;
            [self.navigationController presentViewController:ctr animated:YES completion:nil];
            return;
        }
        [composition composeVideo:_asset1 secondVideoAsset:_asset2];
        
    } else if (indexPath.row == 1) {
        if (!_asset1 || !_asset2) {
            UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
            ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            ctr.delegate = self;
            [self.navigationController presentViewController:ctr animated:YES completion:nil];
            return;
        }
        [composition composeVideo:_asset1 audio:_asset2];
        
    } else if (indexPath.row == 2) {
        if (!_asset1) {
            UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
            ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            ctr.delegate = self;
            [self.navigationController presentViewController:ctr animated:YES completion:nil];
            return;
        }
        [composition composeVideo:_asset1 image:[UIImage imageNamed:@"awesomeface"]];
        
    } else if (indexPath.row == 3) {
        if (!_asset1) {
            UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
            ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            ctr.delegate = self;
            [self.navigationController presentViewController:ctr animated:YES completion:nil];
            return;
        }
        [composition composeVideo:_asset1 gifPath:[[NSBundle mainBundle] pathForResource:@"banana" ofType:@"gif"]];
        
    } else if (indexPath.row == 4) {
        if (!_asset1) {
            UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
            ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            ctr.delegate = self;
            [self.navigationController presentViewController:ctr animated:YES completion:nil];
            return;
        }
        [composition composeVideo:_asset1 filterName:@"CISepiaTone"];
        
    } else if (indexPath.row == self.dataArray.count - 1) {
        _asset1 = nil;
        _asset2 = nil;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (!_asset1) {
        if (@available(iOS 11.0, *)) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:info[UIImagePickerControllerPHAsset]
                                                            options:nil
                                                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                          _asset1 = asset;
                                                      }];
        } else {
            _asset1 = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        }
        
    } else if (!_asset2) {
        if (@available(iOS 11.0, *)) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:info[UIImagePickerControllerPHAsset]
                                                            options:nil
                                                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                          _asset2 = asset;
                                                      }];
        } else {
            _asset2 = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavBarHeight - kTabBarHeight)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reusCellID];
        tableView.rowHeight = 50;
        _tableView = tableView;
    }
    return _tableView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"视频合成", @"音视频合成", @"视频加水印并动画", @"视频加gif水印", @"视频滤镜", @"清空Asset"];
    }
    return _dataArray;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    __weak typeof(self) weakSelf = self;
    UIButton *btn = [self buttonWithTitle:@"选择视频" block:^(id sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
        ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        ctr.delegate = strongSelf;
        [strongSelf.navigationController presentViewController:ctr animated:YES completion:nil];
    }];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(20);
        make.left.mas_equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(120, 45));
    }];
    
    UIButton *composeBtn = [self buttonWithTitle:@"合成" block:^(id sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        FQVideoComposition *composition = [FQVideoComposition new];
        //        [composition composeVideo:_asset1 secondVideoAsset:_asset2];
        //        [composition composeVideo:_asset1 audio:_asset2];
        [composition composeVideo:strongSelf->_asset1 image:[UIImage imageNamed:@"awesomeface"]];
        //        [composition composeVideo:_asset1 gifPath:[[NSBundle mainBundle] pathForResource:@"banana" ofType:@"gif"]];
        //        [composition composeVideo:_asset1 filterName:@"CISepiaTone"];
    }];
    [self.view addSubview:composeBtn];
    [composeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn.mas_right).offset(15);
        make.size.mas_equalTo(btn);
        make.centerY.mas_equalTo(btn);
    }];
    
    UIButton *clearBtn = [self buttonWithTitle:@"清除" block:^(id sender) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_asset1 = nil;
        strongSelf->_asset2 = nil;
    }];
    [self.view addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(composeBtn.mas_right).offset(15);
        make.size.mas_equalTo(btn);
        make.centerY.mas_equalTo(btn);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (!_asset1) {
        if (@available(iOS 11.0, *)) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:info[UIImagePickerControllerPHAsset]
                                                            options:nil
                                                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                          _asset1 = asset;
                                                      }];
        } else {
            _asset1 = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        }
        
    } else if (!_asset2) {
        if (@available(iOS 11.0, *)) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:info[UIImagePickerControllerPHAsset]
                                                            options:nil
                                                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                          _asset2 = asset;
                                                      }];
        } else {
            _asset2 = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}*/

@end
