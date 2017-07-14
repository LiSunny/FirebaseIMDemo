//
//  FileTool.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/14.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import "FileTool.h"

@implementation FileTool


+ (BOOL)isFileExist:(NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}


@end
