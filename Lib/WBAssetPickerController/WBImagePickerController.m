//
//  XFImagePickerController.m
//  WBAssetPickerController
//
//  Created by zwb on 16/1/22.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBImagePickerController.h"
#import "WBImageCollectionController.h"

@implementation WBImagePickerController

- (id)initWithMaxCount:(NSInteger)maxCount completedBlock:(CompletedBlock)completedBlock {
    WBImagePickerView *groupViewController = [[WBImagePickerView alloc]initWithMaxCount:maxCount completedBlock:completedBlock];
    self = [super initWithRootViewController:groupViewController];
    return self;
}

@end


@interface WBImagePickerView () <UITableViewDelegate, UITableViewDataSource, WBImageCollectionDelegate> {
    ALAssetsLibrary *library;
    NSMutableArray *albumGroups;
}
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CompletedBlock completedBlock;
@property (assign, nonatomic) NSInteger maxCount;
@end

@implementation WBImagePickerView

- (id)initWithMaxCount:(NSInteger)maxCount completedBlock:(CompletedBlock)completedBlock {
    self = [super init];
    if (self) {
        self.completedBlock = completedBlock;
        self.maxCount = maxCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self getAllAlbumGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  初始化界面
 */
- (void)initView {
    
    self.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    tableView.delegate     = self;
    tableView.dataSource   = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
}

/**
 *  取消选择
 */
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  获取所有相册
 */
- (void)getAllAlbumGroups {
    albumGroups = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group && [group numberOfAssets]) {
            
            [albumGroups insertObject:group atIndex:0];
            if (stop) {
                [self.tableView reloadData];
                
                // 自动跳到系统相册
                NSNumber *assetsType = [group valueForProperty:ALAssetsGroupPropertyType];
                if (assetsType.longValue == 16) {
                    [self.navigationController pushViewController:[[WBImageCollectionController alloc]initControllerWithALAssetsGroup:group delegate:self maxCount:self.maxCount] animated:NO];
                }
            }
            
        }
        
    } failureBlock:^(NSError *error) {
        
        // 用户拒绝访问
        if (error.code == -3311) {
            // 获取APP名称
            NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
            NSString *appName  = [info objectForKey:@"CFBundleDisplayName"];
            appName            = appName ? appName : [info objectForKey:@"CFBundleName"];

            NSString *message  = [NSString stringWithFormat:@"请在系统设置中允许“%@”访问照片!", appName];
            [[[UIAlertView alloc]initWithTitle:@"无法访问照片" message:message delegate:nil cancelButtonTitle:@"我知道了!" otherButtonTitles:nil] show];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return albumGroups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"photoFrameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.layer.borderWidth = 5;
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    ALAssetsGroup *assetsGroup = [albumGroups objectAtIndex:indexPath.row];
    cell.textLabel.text        = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text  = [NSString stringWithFormat:@"%ld张", assetsGroup.numberOfAssets];
    cell.imageView.image       = [UIImage imageWithCGImage:assetsGroup.posterImage scale:1 orientation:UIImageOrientationUp];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ALAssetsGroup *assetsGroup = [albumGroups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[[WBImageCollectionController alloc]initControllerWithALAssetsGroup:assetsGroup delegate:self maxCount:self.maxCount] animated:YES];
    
}

#pragma mark - XFImageCollectionDelegate
- (void)selectPhotos:(NSArray *)photos {
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.completedBlock(photos);
    }];
}
@end
