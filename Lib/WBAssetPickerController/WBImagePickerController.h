//
//  WBImagePickerController.h
//  WBAssetPickerController
//
//  Created by zwb on 16/1/22.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletedBlock)(NSArray *images);

/**
 *  为筛选器添加导航栏
 */
@interface WBImagePickerController : UINavigationController
- (id)initWithMaxCount:(NSInteger)maxCount completedBlock:(CompletedBlock)completedBlock;
@end


/**
 *  筛选器列表控制器
 */
@interface WBImagePickerView : UIViewController
- (id)initWithMaxCount:(NSInteger)maxCount completedBlock:(CompletedBlock)completedBlock;
@end
