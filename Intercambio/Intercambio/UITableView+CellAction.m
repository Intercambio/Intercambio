//
//  UITableView+CellAction.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "UITableView+CellAction.h"

@implementation UITableView (CellAction)

- (void)performAction:(SEL)action forCell:(UITableViewCell *)cell sender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        if (indexPath) {
            [self.delegate tableView:self performAction:action forRowAtIndexPath:indexPath withSender:sender];
        }
    }
}

@end
