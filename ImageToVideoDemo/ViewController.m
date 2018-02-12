//
//  ViewController.m
//  ImageToVideoDemo
//
//  Created by 刘哲 on 2018/1/31.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import "ViewController.h"
#import "ImagesToVideoTool.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "SelectPhotoViewController.h"
#import "LLVideoPlayerViewController.h"




@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)compoundClick:(id)sender {
    [self selectPhotos];
    NSLog(@"It's a test");
}

- (void) selectPhotos
{

    SelectPhotoViewController *controller = [[SelectPhotoViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navi animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
