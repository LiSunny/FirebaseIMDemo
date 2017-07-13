//
//  ViewController.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/11.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import "ViewController.h"

@import FirebaseDatabase;
@import FirebaseStorage;

@interface ViewController ()
{
    AVPlayer * player;
}

@property (strong, nonatomic) IBOutlet UITextField *inputTextField;

@property (strong, nonatomic) IBOutlet UIButton *sendBtn;

@property (strong, nonatomic) IBOutlet UITextView *chatInforTextView;

@property (nonatomic,strong) FIRDatabaseReference * ref;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    NSString *urlStr= [[NSBundle mainBundle] pathForResource:@"IMG_0001" ofType:@"MOV"];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    
    //2、创建播放器
    player = [AVPlayer playerWithPlayerItem:playerItem];
    
    //3、创建视频显示的图层
    AVPlayerLayer *showVodioLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    showVodioLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
    showVodioLayer.frame = view.frame;
    [view.layer addSublayer:showVodioLayer];
    
    
   
    
    
    
}
- (IBAction)PALY:(id)sender {
    
    [player play];
    
}

- (void)configerDataBase
{
    self.ref = [[FIRDatabase database] referenceFromURL:@"https://chat-53c29.firebaseio.com/"];
    
    //创建两个人的聊天室
    [[[[self.ref child:@"message"] child:@"room1"] child:@"notify"]
     setValue:@{@"type": @"system",@"message":@"欢迎进入聊天室"}];
    
    
    [self observeMessage];
}

- (void)configerStorage
{
    
    //链接Cloud Storage
    FIRStorageReference * storageRef = [[FIRStorage storage] referenceForURL:@"gs://chat-53c29.appspot.com/"];
    //创建 文件路径
    FIRStorageReference * imgRef = [storageRef child:@"icon/user.png"];
    //上传数据
    [self uploadDataToStorage:imgRef];
    //下载数据
    [self downDataFromStorage:imgRef];
    
}
- (void)uploadDataToStorage:(FIRStorageReference *)storageRef
{
    
    NSData * imageData = UIImagePNGRepresentation([UIImage imageNamed:@"1.png"]);
    FIRStorageUploadTask *uploadTask = [storageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
        if (error) {
            
        }else{
            NSURL * downloadURL = metadata.downloadURL;
            NSLog(@"下载URL地址 ====== %@",downloadURL);
        }
        
        
    }];
    
    [uploadTask enqueue];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress
                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                          NSLog(@"progress ----- %@",snapshot.progress);
                      }];

}
- (void)downDataFromStorage:(FIRStorageReference *)storageRef
{
    //获取Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@%@", [paths objectAtIndex:0],@"/img/icon.png"];
    NSLog(@"path:%@", path);
    
    NSURL * url = [NSURL fileURLWithPath:path];
    
    [storageRef writeToFile:url completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        if (error) {
            
        }else{
            NSLog(@"本地URL ===== %@",URL);
        }
    }];
}


- (IBAction)sendClick:(id)sender {
    
    
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString * timestap = [formatter stringFromDate:date];
    
    NSString * sendMessage = self.inputTextField.text;
    
    NSDictionary * messageDic = [NSDictionary dictionaryWithObjectsAndKeys:@"text",@"type", @"me",@"des",sendMessage,@"message",nil];
    
    [[[[self.ref child:@"message"] child:@"room1"] child:timestap] setValue:messageDic];
    
}
- (void)observeMessage
{
    [[[self.ref child:@"message"] child:@"room1"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSLog(@" 发生变化 --------- %@",snapshot);
        NSDictionary * dic = snapshot.value;
        if (self.chatInforTextView.text) {
           self.chatInforTextView.text = [NSString stringWithFormat:@"%@\n%@", self.chatInforTextView.text,[dic objectForKey:@"message"]];
        }
        
        
        
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.inputTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
