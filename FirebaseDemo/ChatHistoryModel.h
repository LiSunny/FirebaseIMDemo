//
//  ChatHistoryModel.h
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatHistoryModel : NSObject

///消息数据源
@property (nonatomic, strong) NSMutableArray * messageDataArr;

///为本地消息数据库加入新消息
+ (NSMutableArray *)refressDataSource:(NSDictionary *)messageDic;


@end
