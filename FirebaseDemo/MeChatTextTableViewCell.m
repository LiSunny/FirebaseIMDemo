//
//  MeChatTextTableViewCell.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import "MeChatTextTableViewCell.h"

@interface MeChatTextTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *inforLable;

@end


@implementation MeChatTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)configerCell:(MessageModel *)model
{
    self.inforLable.text = model.message;
}
@end
