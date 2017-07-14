//
//  MeChatImgTableViewCell.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import "MeChatImgTableViewCell.h"
#import "FileTool.h"
#import "MD5Tools.h"
@import FirebaseStorage;

@interface MeChatImgTableViewCell ()

@property (nonatomic,strong) FIRStorageReference * storageRef;

@property (weak, nonatomic) IBOutlet UIImageView *imageMessageView;

@end

@implementation MeChatImgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configerCell:(MessageModel *)imageModel
{
    
    NSURL * url = [NSURL URLWithString:imageModel.message];
    NSMutableArray * componentsArr = [NSMutableArray arrayWithObject:[url pathComponents]];
    NSMutableArray * inforArr = [componentsArr objectAtIndex:0];
    [inforArr removeObjectsInRange:NSMakeRange(0, inforArr.count -2)];
    NSString * filePath = [inforArr componentsJoinedByString:@"/"];
    
    BOOL fileExist = [FileTool isFileExist:filePath];
    if (fileExist) {
        self.imageMessageView.image = [UIImage imageWithContentsOfFile:filePath];
    }else{
        [self downDataWithFilePath:filePath];
    }
    
    
}
- (void)downDataWithFilePath:(NSString *)storageRefPath
{
    
    self.storageRef = [[FIRStorage storage] referenceForURL:@"gs://chat-53c29.appspot.com/"];
    
    //创建 文件路径
    FIRStorageReference * imgRef = [self.storageRef child:storageRefPath];
    
    NSString * path = [self getFilePath];
    
    NSURL * url = [NSURL fileURLWithPath:path];
    
    [imgRef writeToFile:url completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        
        if (error) {
            
        }else{
            NSLog(@"本地URL ===== %@",URL);
            self.imageMessageView.image = [UIImage imageWithContentsOfFile:path];
        }
    }];
}
- (NSString *)getFilePath
{
    //获取Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //文件名称
    NSString * fileName = [NSString stringWithFormat:@"%@.png",[self getTimeStamp]];
    //生成路径
    NSString *path = [NSString stringWithFormat:@"%@%@%@%@%@", [paths objectAtIndex:0],@"/",[self md5Str:[self getTimeStamp]],@"/img/",fileName];
    NSLog(@"path:%@", path);
    
    return path;
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
- (NSString *)md5Str:(NSString *)str
{
    NSString * md5Str = [MD5Tools MD5ForUpper32Bate:str];
    NSLog(@"大写32位:%@", md5Str);
    return md5Str;
}

@end
