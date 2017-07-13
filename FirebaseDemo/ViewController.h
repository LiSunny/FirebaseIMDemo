//
//  ViewController.h
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/11.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController

@property (strong, nonatomic) AVPlayer *player;//播放器对象

@property (weak, nonatomic) IBOutlet UIView *container; //播放器容器
@property (weak, nonatomic) IBOutlet UIButton *playOrPause; //播放/暂停按钮
@property (weak, nonatomic) IBOutlet UIProgressView *progress;//播放进度

- (IBAction)playClick:(UIButton *)sender;


@end

