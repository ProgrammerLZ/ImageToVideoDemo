//
//  PhotoCell.h
//  ImageToVideoDemo
//
//  Created by 刘哲 on 2018/2/5.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectImage;
- (void) configurePhotoImageWithImage:(UIImage*) image;
@end
