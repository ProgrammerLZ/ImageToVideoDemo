//
//  Transformer.h
//  ImageToVidDemo
//
//  Created by 刘哲 on 2018/1/30.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "util.h"

typedef void(^SuccessBlock)(BOOL success);

typedef NS_ENUM(NSInteger,TransitionMode)
{
    TransitionFadeMode = 0,
    TransitionScrollMode = 1
};

@interface ImagesToVideoTool : NSObject
/**
 *  相框
 **/
@property (nonatomic,strong) UIImage *photoFrame;
/**
 *  浮动图片
 **/
@property (nonatomic,strong) UIImage *animateImage;


- (void)writeImageAsMovie:(NSArray *)array
                   toPath:(NSString*)path
                audioPath:(NSString *)audioPath
                     size:(CGSize)size
                      fps:(int)fps
       animateTransitions:(BOOL)shouldAnimateTransitions
          transitionMode:(TransitionMode) mode
        withCallbackBlock:(SuccessBlock)callbackBlock;

@end
