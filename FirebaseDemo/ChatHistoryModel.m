//
//  ChatHistoryModel.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import "ChatHistoryModel.h"
#import "MessageModel.h"


@implementation ChatHistoryModel


///为本地消息数据库加入新消息
+ (NSMutableArray *)refressDataSource:(NSDictionary *)messageDic
{
    NSMutableArray * dataSourcArr = [NSMutableArray array];
    if ([[messageDic allKeys] containsObject:@"messageType"]) {
        
        if ([[messageDic objectForKey:@"messageType"] isEqualToString:@"text"] || [[messageDic objectForKey:@"messageType"] isEqualToString:@"img"] || [[messageDic objectForKey:@"messageType"] isEqualToString:@"video"]) {
            //文字消息
            MessageModel * model = [[MessageModel alloc] init];
            model.messageType = [messageDic objectForKey:@"messageType"];
            model.message = [messageDic objectForKey:@"message"];
            NSNumber *boolNumber = [messageDic objectForKey:@"direction"];
            model.isMe = [boolNumber boolValue];
            
            [dataSourcArr addObject:model];
        }
        
    }else{
        //消息格式错误无法解析
        return nil;
    }
    
    
    return dataSourcArr;
}

@end
