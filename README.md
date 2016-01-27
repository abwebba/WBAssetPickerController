# WBAssetPickerController

照片批量选择器使用方法
1、把Lib拖进你的工程里面。
2、包含头文件---#import "WBImagePickerController.h"。
3、使用：
[self presentViewController:[[WBImagePickerController alloc]initWithMaxCount:9/*最大选择张数*/ completedBlock:^(NSArray *images) {

  // 得到选择的照片

}] animated:YES completion:nil];
