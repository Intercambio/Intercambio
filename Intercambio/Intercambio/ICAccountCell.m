//
//  ICAccountCell.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountCell.h"
#import "UITableView+CellAction.h"

@implementation ICAccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"702-share"]
                     forState:UIControlStateNormal];
        [shareButton addTarget:self
                        action:@selector(share:)
              forControlEvents:UIControlEventTouchUpInside];
        [shareButton sizeToFit];
        self.accessoryView = shareButton;
    }
    return self;
}

- (IBAction)share:(id)sender
{
    id target = [self targetForAction:@selector(performAction:forCell:sender:) withSender:self];
    if (target) {
        [target performAction:@selector(share:) forCell:self sender:sender];
    }
}

@end
