//
//  ViewController.m
//  WBAssetPickerController
//
//  Created by zwb on 16/1/26.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "ViewController.h"
#import "WBImagePickerController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttom Action
- (IBAction)openAlbum:(id)sender {
    
    [self presentViewController:[[WBImagePickerController alloc]initWithMaxCount:9 completedBlock:^(NSArray *images) {
        
        for (UIView *view in self.scrollView.subviews) {
            [view removeFromSuperview];
        }
        
        for (NSInteger index = 0; index < images.count; index++) {
            
            UIImage *image = [images objectAtIndex:index];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.frame)*index, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)-64)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImage:image];
                                                                                  
            [self.scrollView addSubview:imageView];
        }
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*images.count, CGRectGetHeight(self.scrollView.frame)-64);
        self.scrollView.contentOffset = CGPointMake(0, 0);
        
    }] animated:YES completion:nil];
    
}

@end
