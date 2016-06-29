//
//  ICConversationCell.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 06.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationCell.h"

@implementation ICConversationCell

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = kCFDateFormatterShortStyle;
        dateFormatter.timeStyle = kCFDateFormatterNoStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    });
    return dateFormatter;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.bounds) / 2;
}

- (void)setCellModel:(id<ICConversationViewModel>)cellModel
{
    _cellModel = cellModel;

    self.titleLabel.text = _cellModel.title;
    self.avatarImageView.image = [UIImage imageNamed:@"avatar-normal"];
    self.messageLabel.attributedText = _cellModel.recentMessage.textStorage;

    if (_cellModel.timestamp) {
        self.timestampLabel.text = [[[self class] dateFormatter] stringFromDate:_cellModel.timestamp];
    } else {
        self.timestampLabel.text = nil;
    }
}

@end
