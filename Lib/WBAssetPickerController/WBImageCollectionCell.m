//
//  WBImageCollectionCell.m
//  WBAssetPickerController
//
//  Created by zwb on 16/1/22.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBImageCollectionCell.h"

@implementation WBImageCollectionCell

- (void)awakeFromNib {
    // Initialization code
    NSString *selectImageUrl = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"WBImagePicker.bundle/image/select.png"];
    NSString *unSelectImageUrl = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"WBImagePicker.bundle/image/unselect.png"];
    
    [self.selectButton setImage:[UIImage imageWithContentsOfFile:unSelectImageUrl] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageWithContentsOfFile:selectImageUrl] forState:UIControlStateSelected];
}

@end
