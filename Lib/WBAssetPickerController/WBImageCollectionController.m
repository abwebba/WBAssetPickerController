//
//  WBImageCollectionController.m
//  WBAssetPickerController
//
//  Created by zwb on 16/1/22.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBImageCollectionController.h"
#import "WBImageCollectionCell.h"

@interface WBImageCollectionController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray *assetsArray;
    NSMutableArray *selectAssets;
}
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIActivityIndicatorView *activity;
@property (weak, nonatomic) ALAssetsGroup *assetsGroup;
@property (assign, nonatomic) NSInteger maxCount;
@end

@implementation WBImageCollectionController

- (id)initControllerWithALAssetsGroup:(ALAssetsGroup *)assetsGroup delegate:(id)target maxCount:(NSInteger)maxCount {
    self = [super init];
    if (self) {
        self.assetsGroup = assetsGroup;
        self.delegate = target;
        self.maxCount = maxCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self getAssets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  初始化界面
 */
- (void)initView {
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定(0)" style:UIBarButtonItemStylePlain target:self action:@selector(endSelectPhoto)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    // 每个item大小
    NSInteger space = 3;
    CGFloat itemSize = (CGRectGetWidth([UIScreen mainScreen].bounds)-3*space)/4;
    layout.itemSize  = CGSizeMake(itemSize, itemSize);
    // 间隙
    layout.minimumInteritemSpacing = space;
    layout.minimumLineSpacing      = space;
    //layout.sectionInset            = UIEdgeInsetsMake(space, space, space, space);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    collectionView.backgroundColor   = [UIColor whiteColor];
    collectionView.delegate          = self;
    collectionView.dataSource        = self;
    [collectionView registerNib:[UINib nibWithNibName:@"WBImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionCell"];
    [self.view addSubview:collectionView];
    collectionView.hidden = YES;
    self.collectionView = collectionView;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activity.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [self.view addSubview:activity];
    self.activity = activity;
}

/**
 *  获取相片
 */
- (void)getAssets {
    
    assetsArray = [NSMutableArray array];
    selectAssets = [NSMutableArray array];
    
    [self.activity startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        // 把本相册所有的照片遍历出来
        [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result.thumbnail) {
                [assetsArray addObject:result];
            }
            if (stop && assetsArray.count && assetsArray.count == self.assetsGroup.numberOfAssets) {
                
                [self.collectionView reloadData];
                // 显示最底部
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.collectionView.contentSize.height >= CGRectGetHeight(self.collectionView.frame)) {
                        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height-CGRectGetHeight(self.collectionView.frame))];
                        
                    }
                    self.collectionView.hidden = NO;
                    [self.activity stopAnimating];
                });
                
            }
            
        }];
    });
}

/**
 *  结束选择照片
 */
- (void)endSelectPhoto {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.activity startAnimating];
    
    NSMutableArray *photos = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            for (ALAsset *asset in selectAssets) {
                ALAssetRepresentation* representation = [asset defaultRepresentation];
                UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                [photos addObject:image];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activity stopAnimating];
            
            if ([self.delegate respondsToSelector:@selector(selectPhotos:)]) {
                [self.delegate selectPhotos:photos];
            }
            [self.navigationController popViewControllerAnimated:NO];
        });
    });
    
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return assetsArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WBImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionCell" forIndexPath:indexPath];
    
    ALAsset *asset = [assetsArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail scale:1 orientation:UIImageOrientationUp];
    cell.selectButton.selected = [selectAssets containsObject:asset];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 把选择的加入数组中
    ALAsset *asset = [assetsArray objectAtIndex:indexPath.row];
    
    if ([selectAssets containsObject:asset]) {
        [selectAssets removeObject:asset];
    } else {
        if (selectAssets.count >= self.maxCount) {
            [[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"最多只能选择%ld张照片", self.maxCount] message:nil delegate:nil cancelButtonTitle:@"我知道了!" otherButtonTitles:nil] show];
            return;
        }
        [selectAssets addObject:asset];
    }
    
    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确定(%ld)", selectAssets.count];
    self.navigationItem.rightBarButtonItem.enabled = selectAssets.count ? YES : NO;
    
    WBImageCollectionCell *cell = (WBImageCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected = [selectAssets containsObject:asset];
}
@end
