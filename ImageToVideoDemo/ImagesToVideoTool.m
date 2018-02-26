//
//  Transformer.m
//  ImageToVidDemo
//
//  Created by 刘哲 on 2018/1/30.
//  Copyright © 2018年 刘哲. All rights reserved.
//

#import "ImagesToVideoTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ImagesToVideoTool()
@property (nonatomic,strong) NSString *audioPath;
@end

@implementation ImagesToVideoTool

-(instancetype)init
{
    if (self = [super init]) {
    }
    return self;

}

- (void)writeImageAsMovie:(NSArray <UIImage*>*)array
                   toPath:(NSString*)path
                audioPath:(NSString *)audioPath
                     size:(CGSize)size
                      fps:(int)fps
       animateTransitions:(BOOL)shouldAnimateTransitions
          transitionMode:(TransitionMode)mode
        withCallbackBlock:(SuccessBlock)callbackBlock
{
    NSLog(@"图片->视频：开始");
    self.audioPath = audioPath;
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    if (error) {
        if (callbackBlock) {
            callbackBlock(NO);
        }
        return;
    }
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecJPEG,
                                    AVVideoWidthKey: [NSNumber numberWithInt:size.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:size.height]};
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    

    CMTime presentTime = CMTimeMake(0, fps);
    CVPixelBufferRef buffer;
    CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);

    
    int i = 0;
    while (1)
    {
        if(writerInput.readyForMoreMediaData){
            presentTime = CMTimeMake(i*2, fps);

            if (i >= [array count]) {
                buffer = NULL;
            } else {
                buffer = [self pixelBufferFromCGImage:[array[i] CGImage]
                                                 size:size];
            }
            if (buffer) {

                BOOL appendSuccess = [self appendToAdapter:adaptor
                                               pixelBuffer:buffer
                                                    atTime:presentTime
                                                 withInput:writerInput];
                NSAssert(appendSuccess, @"Failed to append image buffer");

                if (shouldAnimateTransitions && i + 1 < array.count) {

                    
                    switch (mode) {
                        case TransitionFadeMode:
                        {
                            CMTime fadeTime = CMTimeMake(2, fps*TRANSITIONFRAMECOUNT);
                            for (int b = 0; b < FRAMESTOWAITBEFORETRANSION; b++) {
                                presentTime = CMTimeAdd(presentTime, fadeTime);
                            }
                            NSInteger framesToFadeCount = TRANSITIONFRAMECOUNT - FRAMESTOWAITBEFORETRANSION;
                            for (double j = 1; j <= framesToFadeCount; j++) {
                                
                                    UIImage *baseImage = [array objectAtIndex:i];
                                    UIImage *fadeinImage = [array objectAtIndex:i+1];
                                    buffer = [self crossFadeImage:baseImage
                                                          toImage:fadeinImage
                                                           atSize:size
                                                    withFadeAlpha:j/framesToFadeCount
                                                    withBaseAlpha:1 - j/framesToFadeCount];

                                    BOOL appendSuccess = [self appendToAdapter:adaptor
                                                                   pixelBuffer:buffer
                                                                        atTime:presentTime
                                                                     withInput:writerInput];
                                    presentTime = CMTimeAdd(presentTime, fadeTime);
                                    NSAssert(appendSuccess, @"Failed to append");

                            }
                        }
                            break;
                            
                            
                        case TransitionScrollMode:
                        {
                            CMTime scrollTime = CMTimeMake(2, fps*TRANSITIONFRAMECOUNT);//Time for each frame.
                            
                            for (int b = 0; b < FRAMESTOWAITBEFORETRANSION; b++) {
                                presentTime = CMTimeAdd(presentTime, scrollTime);
                            }
                            NSInteger framesToScrollCount = TRANSITIONFRAMECOUNT - FRAMESTOWAITBEFORETRANSION;
                            
                            CGFloat differentValue = (float)size.width / (float)framesToScrollCount;

                            for (double j = 0; j < framesToScrollCount; j++) {

                                    //Caculate position of the scroll image.
                                    CGImageRef baseImage = [array objectAtIndex:i].CGImage;
                                    CGImageRef fadeinImage = [array objectAtIndex:i+1].CGImage;
                                    CGPoint scrollPosition = CGPointMake(-size.width + (j * differentValue),fabs((size.height - CGImageGetHeight( baseImage ))) / 2);
                                    CGPoint basePostion = CGPointMake(j*differentValue, fabs((size.height - CGImageGetHeight( baseImage ))) / 2);
                                    buffer = [self crossScrollImage:baseImage
                                                            toImage:fadeinImage
                                                             atSize:size
                                                   withScrollOrigin:scrollPosition
                                                         baseOrigin:basePostion];
                                    
                                    BOOL appendSuccess = [self appendToAdapter:adaptor
                                                                   pixelBuffer:buffer
                                                                        atTime:presentTime
                                                                     withInput:writerInput];
                                    presentTime = CMTimeAdd(presentTime, scrollTime);
                                    NSAssert(appendSuccess, @"Failed to append");
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                i++;
            } else {
                //Finish the session:
                [writerInput markAsFinished];
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    if (videoWriter.status == AVAssetWriterStatusCompleted) {
                        NSLog(@"图片->视频：转换成功");
                        //FIXME
//                        [self generateWarterMarkWithVideoPath:path size:size callBackBlock:callbackBlock];
                        [self addMusicForVideoWithVideoPath:path audioPath:audioPath callBackBlock:callbackBlock];
                    } else {
                        if (callbackBlock) {
                            NSLog(@"图片->视频：转换失败\n失败原因：%@",videoWriter.error);
                            callbackBlock(NO);
                        }
                    }
                }];
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                
                //TEST
                
                
                //TEST
                
                
                //TEST
                
                
                //TEST
                
                
                //TEST
                
                
                //TEST 

                break;
            }
        }
    }
}


- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
                                      size:(CGSize)imageSize
{

    CGRect drawRect = [self getAppropriateImageRectWithImage:image videoSize:DEFAULTFRAMESIZE];
    
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          imageSize.width,
                                          imageSize.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 8,
                                                 imageSize.width * 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);

    NSParameterAssert(context);
    CGContextDrawImage(context,
                       drawRect,
                       image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(CVPixelBufferRef) crossScrollImage:(CGImageRef)baseImage
                             toImage:(CGImageRef)scrollImage
                              atSize:(CGSize)imageSize
                    withScrollOrigin:(CGPoint)scrollOrigin
                          baseOrigin:(CGPoint)baseOrigin
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 8,
                                                 4*imageSize.width,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);

    //Core code begin
    CGFloat scrollImageRealWidth = CGImageGetWidth(scrollImage);
    CGFloat scrollImageRealHeight = CGImageGetHeight(scrollImage);
    CGFloat scrollImagePresentHeight = (imageSize.width / scrollImageRealWidth) * scrollImageRealHeight;
    CGRect scrollDrawRect = CGRectMake(scrollOrigin.x,
                                 fabs((imageSize.height - scrollImagePresentHeight)/2),
                                 imageSize.width,
                                 scrollImagePresentHeight );
    
    CGFloat baseImageRealWidth = CGImageGetWidth(baseImage);
    CGFloat baseImageRealHeight = CGImageGetHeight(baseImage);
    CGFloat baseImagePresentHeight = (imageSize.width / baseImageRealWidth) * baseImageRealHeight;
    
    CGRect baseDrawRect = CGRectMake(baseOrigin.x,
                                 fabs((imageSize.height - baseImagePresentHeight)/2),
                                     imageSize.width,
                                     baseImagePresentHeight);

    CGContextDrawImage(context, scrollDrawRect, scrollImage);
    CGContextDrawImage(context, baseDrawRect,baseImage);
    //End
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (CVPixelBufferRef)crossFadeImage:(UIImage *)baseImage
                           toImage:(UIImage *)fadeInImage
                            atSize:(CGSize)imageSize
                     withFadeAlpha:(CGFloat)fadeAlpha
                     withBaseAlpha:(CGFloat) baseAlpha

{
    
    CGImageRef myBaseImage = baseImage.CGImage;
    CGImageRef myFadeInImage = fadeInImage.CGImage;

    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGRect fadeImageDrawRect = [self getAppropriateImageRectWithImage:myFadeInImage videoSize:imageSize];
    CGContextBeginTransparencyLayer(context, NULL);
    CGContextSetAlpha( context, fadeAlpha );
    CGContextDrawImage(context, fadeImageDrawRect, myFadeInImage);

    CGRect baseImageDrawRect = [self getAppropriateImageRectWithImage:myBaseImage videoSize:imageSize];
    CGContextSetAlpha(context, baseAlpha);
    CGContextDrawImage(context, baseImageDrawRect, myBaseImage);
    CGContextEndTransparencyLayer(context);
    

    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)presentTime
              withInput:(AVAssetWriterInput*)writerInput
{
    while (!writerInput.readyForMoreMediaData) {
        usleep(1);
    }
    BOOL appendSucc = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
    CVPixelBufferRelease(buffer);
    return appendSucc;
}

- (CGRect) getAppropriateImageRectWithImage:(CGImageRef) image videoSize:(CGSize) videoSize
{
    CGRect drawRect = CGRectZero;
    CGFloat realWidth = CGImageGetWidth(image);
    CGFloat realHeight = CGImageGetHeight(image);
    if (realHeight > realWidth) {
        CGFloat presentWidth = ( videoSize.height / realHeight) * realWidth;
        drawRect = CGRectMake((videoSize.width - presentWidth) / 2,
                              0,
                              presentWidth,
                              videoSize.height);
    }else if (realWidth > realHeight){
        CGFloat presentHeight = (videoSize.width / realWidth) * realHeight;
        drawRect = CGRectMake(0,
                              (videoSize.height - presentHeight)/2,
                              videoSize.width,
                              presentHeight);
    }else{
        drawRect = CGRectMake(0, 0, videoSize.width, videoSize.height);
    }
    return drawRect;
}

- (void) generateWarterMarkWithVideoPath:(NSString *) v_strVideoPath
                                    size:(CGSize) size
                           callBackBlock:(SuccessBlock) callBack
{
    NSLog(@"开始生成水印");
    AVMutableComposition *avMutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *avMutableCompositionTrack = [avMutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:1];
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:v_strVideoPath]];
    AVAssetTrack *avAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    NSError *error = nil;
    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:avAssetTrack atTime:kCMTimeZero error:&error];
    
    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition] ;
    
    avMutableVideoComposition.renderSize = size;
    
    avMutableVideoComposition.frameDuration = CMTimeMake(1, 24);
    UIImage* waterMark=self.photoFrame;
    
    CALayer* imageLayer=[CALayer layer];
    imageLayer.contents=(id)waterMark.CGImage;
    imageLayer.frame=CGRectMake(0,0,size.width,size.height);
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, avMutableVideoComposition.renderSize.width, avMutableVideoComposition.renderSize.height);
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, avMutableVideoComposition.renderSize.width, avMutableVideoComposition.renderSize.height);
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:imageLayer];
    
    if (self.animateImage != nil) {
        
        int loopTime = 30;
        for (int i = 0; i < loopTime; i++) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            animation.repeatCount = 0;
            animation.fromValue=[NSNumber numberWithFloat:0.0];
            animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
            animation.fillMode = kCAFillModeForwards;
            animation.removedOnCompletion = NO;
            animation.beginTime = AVCoreAnimationBeginTimeAtZero;
            
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
            moveAnimation.fillMode = kCAFillModeForwards;
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
            
            UIImage *animationImage = self.animateImage;
            CALayer *starLayer = [CALayer layer];
            [starLayer setContents:(id)[animationImage CGImage]];
            int x = arc4random() % 480;
            int y = (arc4random() % 1000) - 1000;
            float duration = (float)(size.height + 20 - y) / 48.f;
            animation.duration = duration;
            moveAnimation.duration = duration;
            moveAnimation.fromValue = [NSNumber numberWithFloat:y];
            moveAnimation.toValue = [NSNumber numberWithFloat:size.height + 20];
            int width = arc4random() % 40;
            starLayer.frame = CGRectMake(x, y, width, width);
            [starLayer setMasksToBounds:YES];
            [starLayer addAnimation:animation forKey:@"rotation"];
            [starLayer addAnimation:moveAnimation forKey:@"position"];
            
            [parentLayer addSublayer:starLayer];
        }
        
    }
    
    avMutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [avMutableComposition duration])];
    AVMutableVideoCompositionLayerInstruction *avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
    [avMutableVideoCompositionInstruction setLayerInstructions:[NSArray arrayWithObject:avMutableVideoCompositionLayerInstruction]];
    avMutableVideoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
    
    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
    [avAssetExportSession setOutputURL:[NSURL fileURLWithPath:v_strVideoPath]];
    [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
    [avAssetExportSession setShouldOptimizeForNetworkUse:NO];

    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:v_strVideoPath]) {
        [fm removeItemAtPath:v_strVideoPath error:nil];
    }

    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
        
        switch (avAssetExportSession.status) {
                
            case AVAssetExportSessionStatusFailed:
                NSLog(@"水印生成失败");
                if (callBack) {
                    callBack(NO);
                }
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"水印生成成功");
                if (callBack) {
                    [self addMusicForVideoWithVideoPath:v_strVideoPath audioPath:self.audioPath callBackBlock:callBack];
                }
                
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"水印生成失败");
                callBack(NO);
                break;
                
            default:
                break;
        }
    }];
}

- (void) addMusicForVideoWithVideoPath:(NSString *) v_strVideoPath
                             audioPath:(NSString *) v_strAudioPath
                         callBackBlock:(SuccessBlock)callBack
{
    NSLog(@"开始添加音频");
    AVAsset *video = [AVAsset assetWithURL:[NSURL fileURLWithPath:v_strVideoPath]];
    AVAsset *audio = [AVAsset assetWithURL:[NSURL fileURLWithPath:v_strAudioPath]];
    AVAssetTrack *vTrack = [[video tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *aTrack = [[audio tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *visualTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:1];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error;
    [visualTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video.duration) ofTrack:vTrack atTime:kCMTimeZero error:&error];
    if (error) {
        NSLog(@"video composition failed! error:%@", error);
    }
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video.duration) ofTrack:aTrack atTime:kCMTimeZero error:&error];
    if (error) {
        NSLog(@"audio composition failed! error:%@", error);
    }
    
    //Set ramp for music.
    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    
    CMTime startTime = CMTimeMake((composition.duration.value / composition.duration.timescale) * 0.8, 1);
    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(startTime, CMTimeSubtract(composition.duration, startTime))];
    mutableAudioMix.inputParameters = @[mixParameters];
    
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:v_strVideoPath]) {
        NSLog(@"video is have. then delete that");
        if ([fm removeItemAtPath:v_strVideoPath error:&error]) {
            NSLog(@"delete is ok");
        }else {
            NSLog(@"delete is error = %@",error.description);
        }
    }
    
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporter.audioMix = mutableAudioMix;
    exporter.outputURL = [NSURL fileURLWithPath:v_strVideoPath];
    exporter.outputFileType = AVFileTypeMPEG4;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.error) {
            callBack(NO);
            NSLog(@"音频添加失败");
        }else{
            NSLog(@"音频添加成功");
            callBack(YES);
        }
    }];
}
@end
