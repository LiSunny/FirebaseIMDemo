//
//  ChatViewController.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

/**
 *
 *
 */

#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ChatHistoryModel.h"
#import "MeChatTextTableViewCell.h"
#import "OtherTextTableViewCell.h"
#import "MeChatImgTableViewCell.h"
#import "OtherImgTableViewCell.h"
#import "MeChatVideoTableViewCell.h"
#import "OtherVidelTableViewCell.h"
@import FirebaseDatabase;
@import FirebaseStorage;

#define    MeChatTextTableViewCellIdent    @"MeChatTextTableViewCell.h"
#define    OtherTextTableViewCellIdent       @"OtherTextTableViewCell.h"
#define    MeChatImgTableViewCellIdent     @"MeChatImgTableViewCell.h"
#define    OtherImgTableViewCellIdent        @"OtherImgTableViewCell.h"
#define    MeChatVideoTableViewCellIdent  @"MeChatVideoTableViewCell.h"
#define    OtherVidelTableViewCellIdent      @"OtherVidelTableViewCell.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) AVPlayer * player;

@property (nonatomic,strong) NSMutableArray * tableDataSourcArr;

///图片选择器
@property (nonatomic, strong) UIImagePickerController * imgPickController;

@property (nonatomic,strong) FIRDatabaseReference * ref;

///
@property (nonatomic, strong) FIRStorageReference * sotrageRef;

@property(nonatomic,assign) BOOL keyBoardlsVisible;

@property (strong, nonatomic) IBOutlet UITableView *chatListTableView;

@property (strong, nonatomic) IBOutlet UIButton *voiceBtn;

@property (strong, nonatomic) IBOutlet UIButton *addBtn;

@property (strong, nonatomic) IBOutlet UITextField *inputTextField;

@property (weak, nonatomic) IBOutlet UIView *toolBarView;

@end

@implementation ChatViewController


- (UIImagePickerController *)imgPickController
{
    if (!_imgPickController) {
        
        _imgPickController = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
            _imgPickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        _imgPickController.delegate = self;
    }
    return _imgPickController;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.keyBoardlsVisible = NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableDataSourcArr = [NSMutableArray array];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    
    self.inputTextField.delegate = self;
    self.inputTextField.returnKeyType = UIReturnKeySend;
    
    self.chatListTableView.delegate = self;
    self.chatListTableView.dataSource = self;
    self.chatListTableView.tableFooterView = [[UIView alloc] init];
    [self.chatListTableView registerNib:[UINib nibWithNibName:@"MeChatTextTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MeChatTextTableViewCellIdent];
    [self.chatListTableView registerNib:[UINib nibWithNibName:@"OtherTextTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:OtherTextTableViewCellIdent];
    [self.chatListTableView registerNib:[UINib nibWithNibName:@"MeChatImgTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MeChatImgTableViewCellIdent];
    [self.chatListTableView registerNib:[UINib nibWithNibName:@"OtherImgTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:OtherImgTableViewCellIdent];
    [self.chatListTableView registerNib:[UINib nibWithNibName:@"MeChatVideoTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MeChatVideoTableViewCellIdent];
    [self.chatListTableView registerNib:[UINib nibWithNibName:@"OtherVidelTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:OtherVidelTableViewCellIdent];
    
    self.chatListTableView.rowHeight = 63;
    
    [self configerDataBase];
    
    [self configerStorage];
    
    
}

- (void)configerDataBase
{
    self.ref = [[FIRDatabase database] referenceFromURL:@"https://chat-53c29.firebaseio.com/"];
    
    //创建两个人的聊天室
    [[[[self.ref child:@"message"] child:@"room1"] child:@"notify"]
     setValue:@{@"messageType": @"system",@"message":@"欢迎进入聊天室"}];

    [self observeMessage];
}

- (void)configerStorage
{
    
    //链接Cloud Storage
    self.sotrageRef = [[FIRStorage storage] referenceForURL:@"gs://chat-53c29.appspot.com/"];
    
}

- (void)observeMessage
{
    
    [[[self.ref child:@"message"] child:@"room1"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSLog(@" 发生变化 --------- %@",snapshot);
        NSDictionary * dic = snapshot.value;
        
        if ([[dic allKeys] containsObject:@"messageType"]) {
            if ([[dic objectForKey:@"messageType"] isEqualToString:@"text"] || [[dic objectForKey:@"messageType"] isEqualToString:@"img"] || [[dic objectForKey:@"messageType"] isEqualToString:@"video"]) {
                
                NSMutableArray * dataSourceArr =  [ChatHistoryModel refressDataSource:dic];
                [self.tableDataSourcArr addObjectsFromArray:dataSourceArr];
                NSLog(@"tableview数据源 %@",self.tableDataSourcArr);
                [self.chatListTableView reloadData];
                
                if (self.chatListTableView.contentSize.height > [UIScreen mainScreen].bounds.size.height) {
                   NSIndexPath * path = [NSIndexPath indexPathForRow:self.tableDataSourcArr.count -1 inSection:0];
                    [self.chatListTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
            }
        }
        
    }];
}
#pragma mark 交互
- (IBAction)functionBtn:(id)sender {
    
    
    [self presentViewController:self.imgPickController animated:YES completion:^{
        
    }];
    
    
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString * filePath = [NSString stringWithFormat:@"room1/%@.png",[self getTimeStamp]];
        
        //创建 文件路径
        FIRStorageReference * imgRef = [self.sotrageRef child:filePath];
        
        NSData * imageData = UIImagePNGRepresentation(image);
        
        FIRStorageUploadTask *uploadTask = [imgRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            
            if (error) {
                
            }else{
                NSURL * downloadURL = metadata.downloadURL;
                NSLog(@"下载URL地址 ====== %@",downloadURL);
                NSString * urlStr = [NSString stringWithFormat:@"%@",downloadURL];
                NSDictionary * messageDic = [NSDictionary dictionaryWithObjectsAndKeys:urlStr,@"message",[NSNumber numberWithBool:YES],@"direction",@"img",@"messageType", nil];
                
                [self sendImageMessage:messageDic timeStamp:[self getTimeStamp]];
                
            }
            
            
        }];
        
        [uploadTask enqueue];
        
    }];
    
}

#pragma mark Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    
    // 获取通知的信息字典
    NSDictionary *userInfo = [notification userInfo];
    
    // 获取键盘弹出后的rect
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
   
    self.toolBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -(keyboardRect.size.height + 50), keyboardRect.size.width, 50);

}
- (void) keyboardWillHide:(NSNotification *)note{
    
    self.toolBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
    
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel * model = [[MessageModel alloc] init];
    model = [self.tableDataSourcArr objectAtIndex:indexPath.row];
    if ([model.messageType isEqualToString:@"text"]) {
        return 63.f;
    }else if ([model.messageType isEqualToString:@"img"]){
        return 169.f;
    }else{
        return 141.f;
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataSourcArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel * model = [[MessageModel alloc] init];
    model = [self.tableDataSourcArr objectAtIndex:indexPath.row];
    
    if (model.isMe) {
        
        if ([model.messageType isEqualToString:@"text"]) {
            MeChatTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:MeChatTextTableViewCellIdent];
            [cell configerCell:model];
            
            return cell;
        }else if ([model.messageType isEqualToString:@"img"]){
            
            MeChatImgTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:MeChatImgTableViewCellIdent];
            [cell configerCell:model];
            return cell;
        }else{
            
            MeChatVideoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:MeChatVideoTableViewCellIdent];
            [cell configerCell:model];
            
            return cell;
            
        }
        
        
        
    }else{
        
        if ([model.messageType isEqualToString:@"text"]) {
            OtherTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:OtherTextTableViewCellIdent];
            [cell configerCell:model];
            return cell;
        }else if ([model.messageType isEqualToString:@"img"]){
            OtherImgTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:OtherImgTableViewCellIdent];
            [cell configerCell:model];
            return cell;
        }else{
            
            OtherVidelTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:OtherVidelTableViewCellIdent];
            
            [cell configerCell:model];
            return cell;
        }
        
        
   }
    
    
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //获取要发送消息
    NSString * sendMessage = textField.text;
    
    NSDictionary * messageDic = [NSDictionary dictionaryWithObjectsAndKeys:sendMessage,@"message",[NSNumber numberWithBool:YES],@"direction",@"text",@"messageType", nil];
    //发送消息
    [self sendMessage:messageDic timeStamp:[self getTimeStamp]];
    //输入框清空
    textField.text = @"";
    
    [self.inputTextField resignFirstResponder];
    return YES;
}
- (NSString *)getTimeStamp
{
    //包装数据
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString * timestap = [formatter stringFromDate:date];
    return timestap;
}
///发送文字消息
- (void)sendMessage:(NSDictionary *)dic timeStamp:(NSString *)stamp
{
    [[[[self.ref child:@"message"] child:@"room1"] child:stamp] setValue:dic];
}
///发送图片消息
- (void)sendImageMessage:(NSDictionary *)dic timeStamp:(NSString *)stamp
{
    [[[[self.ref child:@"message"] child:@"room1"] child:stamp] setValue:dic];
}


- (void)uploadDataToStorage:(FIRStorageReference *)storageRef fileName:(NSString *)imageName
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
