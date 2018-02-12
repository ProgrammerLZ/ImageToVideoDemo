//
//  PhotoCell.m
//  ImageToVideoDemo
//
//  Created by 刘哲 on 2018/2/5.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configurePhotoImageWithImage:(UIImage *)image
{
    if (image) {
        if (self.photoImage.image  == image) {
            return;
        }
        self.photoImage.image = image;
    }
}

@end
