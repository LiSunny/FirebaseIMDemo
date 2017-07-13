//
//  OtherTextTableViewCell.m
//  FirebaseDemo
//
//  Created by HeavenLi on 2017/7/12.
//  Copyright © 2017年 HeavenLi. All rights reserved.
//

#import "OtherTextTableViewCell.h"

@interface OtherTextTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *inforLable;

@end

@implementation OtherTextTableViewCell

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
