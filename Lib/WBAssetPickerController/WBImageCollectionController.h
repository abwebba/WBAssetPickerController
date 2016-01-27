//
//  WBImageCollectionController.h
//  WBAssetPickerController
//
//  Created by zwb on 16/1/22.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>



@protocol WBImageCollectionDelegate
@optional
- (void)selectPhotos:(NSArray *)photos;
@end

@interface WBImageCollectionController : UIViewController
@property (assign) NSObject<WBImageCollectionDelegate> *delegate;
- (id)initControllerWithALAssetsGroup:(ALAssetsGroup *)assetsGroup delegate:(id)target maxCount:(NSInteger)maxCount;
@end
