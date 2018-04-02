//
//  SlideShowController.m
//  ImageToVideoDemo
//
//  Created by 刘哲 on 2018/2/27.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import "SlideShowController.h"
#import "util.h"
#import <AVFoundation/AVFoundation.h>
@interface SlideShowController ()<CAAnimationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *warterMarkImage;
@property (weak, nonatomic) IBOutlet UIImageView *frontImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic,strong) NSArray * imageArr;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) AVAudioPlayer *player;
@end

@implementation SlideShowController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataInit];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self uiInit];
    [self startShow];
    [self playBackMusic];
}

-(id)initWithImageArray:(NSArray *)imageArr
{
    if ([super init]) {
        self.imageArr = imageArr;
    }
    
    return self;
}

- (void) uiInit
{
    self.frontImage.image = [self.imageArr objectAtIndex:0];
    self.warterMarkImage.image = [UIImage imageNamed:@"HeadFrame"];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.backButton.layer.cornerRadius = self.backButton.frame.size.width / 2;
}

- (IBAction)dissmiss:(id)sender
{
    [self.timer invalidate];
    self.timer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) dataInit
{
}

/**
 *  开始展示动画
 **/
- (void) startShow
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(fadeAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    int loopTime = (int)self.imageArr.count;
    for (int i = 0; i < loopTime; i++) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.repeatCount = 0;
        animation.fromValue=[NSNumber numberWithFloat:0.0];
        animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;

        CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        moveAnimation.fillMode = kCAFillModeForwards;
        moveAnimation.removedOnCompletion = NO;

        UIImage *animationImage = [UIImage imageNamed:@"star"];
        CALayer *starLayer = [CALayer layer];
        [starLayer setContents:(id)[animationImage CGImage]];
        int x = arc4random() % 480;
        int y = (arc4random() % 1000) - 1000;
        float duration = (float)(DEFAULTFRAMESIZE.height + 20 - y) / 48.f;
        animation.duration = duration;
        moveAnimation.duration = duration;
        moveAnimation.fromValue = [NSNumber numberWithFloat:y];
        moveAnimation.toValue = [NSNumber numberWithFloat:DEFAULTFRAMESIZE.height + 20];
        int width = arc4random() % 30;
        starLayer.frame = CGRectMake(x, y, width, width);
        [starLayer setMasksToBounds:YES];
        [starLayer addAnimation:animation forKey:@"rotation"];
        [starLayer addAnimation:moveAnimation forKey:@"position"];
        [self.warterMarkImage.layer addSublayer:starLayer];
    }
}

/**
 *  过渡效果
 **/
- (void) fadeAnimation
{
    static int index = 1;
    if (index > self.imageArr.count -1) {
        [self endSHow];
        return;
    }
    

    [UIView transitionWithView:self.frontImage duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.frontImage.image = [self.imageArr objectAtIndex:index];
    } completion:^(BOOL finished) {
        index ++;
    }];

}

/**
 *  播放到最后一张图片将动画移除
 **/
- (void) endSHow
{
    [self.timer invalidate];
    self.timer = nil;
}

/**
 *  播放背景音乐
 **/
- (void) playBackMusic
{
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"song.mp3" ofType:nil];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:musicPath] error:&error];
    
    if ([self.player prepareToPlay]) {
        [self.player play];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
