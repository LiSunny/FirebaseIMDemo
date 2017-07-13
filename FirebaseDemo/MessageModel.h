//
//  MessageModel.h
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

///类型
@property (nonatomic, strong) NSString * messageType;

///信息
@property (nonatomic, strong) NSString * message;

///来源
@property (nonatomic, assign) BOOL  isMe;

@end
