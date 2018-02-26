//
//  SelectPhotoViewController.m
//  ImageToVideoDemo
//
//  Created by 刘哲 on 2018/2/5.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import "SelectPhotoViewController.h"
#import <Photos/Photos.h>
#import "PhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImagesToVideoTool.h"
#import "LLVideoPlayerViewController.h"
#import "Tool.h"

#define ITEM_SIZE CGSizeMake(250,250)
@interface SelectPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic,strong) ImagesToVideoTool *transformer;
@property (nonatomic,strong) NSMutableArray <NSIndexPath *>*selectIndexPathArr;
@property (nonatomic,strong) PHFetchResult *fetchResult;
@property (nonatomic,strong) PHCachingImageManager *cachingImageManager;
@end

@implementation SelectPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataInit];
    [self uiInit];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void) uiInit
{
    float space = 5.f;
    
    CGSize itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 3*space)/4  , ([UIScreen mainScreen].bounds.size.width - 3*space)/ 4 );
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = itemSize;
    flow.minimumLineSpacing = space;
    flow.minimumInteritemSpacing = space;
    self.collectionView.collectionViewLayout = flow;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([PhotoCell class])];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"合成" style:UIBarButtonItemStylePlain target:self action:@selector(ok)];
}

- (void) dataInit
{
    self.selectIndexPathArr = [NSMutableArray array];
    self.transformer = [ImagesToVideoTool new];
    [self precachePhotos];
    //FIXME:Test code.
    for (int i = 0; i < 100; i++) {
        [self.selectIndexPathArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
}

- (void) precachePhotos
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    self.fetchResult = fetchResult;
    
    NSMutableArray *assetsArr = [NSMutableArray array];
    for (int i = 0; i < fetchResult.count;i++)
    {
        @autoreleasepool
        {
            PHAsset *asset = [fetchResult objectAtIndex:i];
            [assetsArr addObject:asset];
        }
    }
    
    
    self.cachingImageManager = [[PHCachingImageManager alloc] init];
    self.cachingImageManager.allowsCachingHighQualityImages = YES;
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [self.cachingImageManager startCachingImagesForAssets:assetsArr targetSize:ITEM_SIZE contentMode:PHImageContentModeAspectFill options:requestOptions];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCell class]) forIndexPath:indexPath];
    
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    [self.cachingImageManager requestImageForAsset:asset targetSize:ITEM_SIZE
                                       contentMode:PHImageContentModeAspectFill
                                           options:options
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         @autoreleasepool
                                         {
                                             if (result != nil) {
                                                 cell.photoImage.image = result;
                                             }
                                         }
                                     }];
    
    if (self.selectIndexPathArr.count == 0) {
        cell.selectImage.hidden = YES;
    }else{
        if ([self.selectIndexPathArr containsObject:indexPath]) {
            cell.selectImage.hidden = NO;
        }else{
            cell.selectImage.hidden = YES;
        }
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectIndexPathArr containsObject:indexPath]) {
        [self.selectIndexPathArr removeObject:indexPath];
    }else{
        [self.selectIndexPathArr addObject:indexPath];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) ok
{
    if ([self.activity isAnimating]) {
        return;
    }
    [self.activity startAnimating];
    
    NSLog(@"开始合成");
    [Tool testMethod_GetCurrentTime];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *imageArr = [NSMutableArray array];
        for (int i = 0; i < weakSelf.selectIndexPathArr.count; i++) {
            NSIndexPath *indexPath = weakSelf.selectIndexPathArr[i];
            
            PHAsset *asset = [weakSelf.fetchResult objectAtIndex:indexPath.item];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.synchronous = YES;
            
            
            [weakSelf.cachingImageManager requestImageForAsset:asset
                                                       targetSize:DEFAULTFRAMESIZE
                                               contentMode:PHImageContentModeDefault
                                                          options:options
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
             {
                     if (result != nil) {
                         [imageArr addObject:result];
                     }else{
                         NSLog(@"Result is nil");
                     }
                     if (imageArr.count == weakSelf.selectIndexPathArr.count) {
                         NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//                         NSString *path = @"/Users/liuzhe/Desktop";
                         path =[path stringByAppendingString:@"/movie.mp4"];
                         [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                         NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"song.mp3" ofType:nil];
                         weakSelf.transformer.animateImage = [UIImage imageNamed:@"star"];
                         weakSelf.transformer.photoFrame = [UIImage imageNamed:@"HeadFrame"];
                         [weakSelf.transformer writeImageAsMovie:imageArr
                                                          toPath:path
                                                       audioPath:musicPath
                                                            size:DEFAULTFRAMESIZE
                                                             fps:DEFAULTFRAMERATE
                                              animateTransitions:YES
                                                  transitionMode:TransitionFadeMode
                                               withCallbackBlock:^(BOOL success) {
                                                   if (success) {
                                                       NSLog(@"TRANSFORMER SUCCESS");
                                                       [Tool testMethod_GetCurrentTime];
                                                       NSLog(@"合成完毕");
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [weakSelf.activity stopAnimating];
                                                           [Tool testMethod_GetCurrentTime];
                                                           LLVideoPlayerViewController *videoPlayerVC = [[LLVideoPlayerViewController alloc] initWithVideoUrl:[NSURL fileURLWithPath:path]];
                                                           
                                                           [weakSelf presentViewController:videoPlayerVC animated:YES completion:^{
                                                           }];
                                                       });
                                                   }else{
                                                       NSLog(@"TRANSFORMER FAILED");
                                                   }
                                               }];
                     }
             }];
        }
    });
}

-(void)dealloc
{
    NSLog(@"Dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
