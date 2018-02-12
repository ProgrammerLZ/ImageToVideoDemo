# ImageToVideoDemo
ImageToVideoDemo is a demo for converting a set of images to video.

## Installation
You can include it into your project by adding the source file directly.

## Usage
~~~
    NSArray *imageArr;//A array with images.
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//The path of video.
    path =[path stringByAppendingString:@"/movie.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"song.mp3" ofType:nil];
    
    self.tool = [[ImagesToVideoTool alloc] init];
    self.tool.animateImage = [UIImage imageNamed:@"star"];
    self.tool.photoFrame = [UIImage imageNamed:@"HeadFrame"];
    [self.tool writeImageAsMovie:imageArr
                                     toPath:path
                                  audioPath:musicPath
                                       size:DEFAULTFRAMESIZE
                                        fps:DEFAULTFRAMERATE
                         animateTransitions:YES
                             transitionMode:TransitionFadeMode
                          withCallbackBlock:^(BOOL success) {
                              if (success) {
                                  NSLog(@"TRANSFORMER SUCCESS");
                              }else{
                                  NSLog(@"TRANSFORMER FAILED");
                              }
                          }];

~~~
