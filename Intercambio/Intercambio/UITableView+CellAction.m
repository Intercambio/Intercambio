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

- (void)setValue:(id)value forCell:(UITableViewCell *)cell sender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableView:setValue:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        if (indexPath) {
            id<UITableViewDelegateCellAction> delegate = (id<UITableViewDelegateCellAction>)self.delegate;
            [delegate tableView:self setValue:value forRowAtIndexPath:indexPath];
        }
    }
}

@end

@implementation UITableViewCell (CellAction)

- (void)performAction:(nonnull SEL)action sender:(nullable id)sender
{
    id target = [self targetForAction:@selector(performAction:forCell:sender:) withSender:self];
    if (target) {
        [target performAction:action forCell:self sender:sender];
    }
}

- (void)setValue:(id)value sender:(nullable id)sender
{
    id target = [self targetForAction:@selector(setValue:forCell:sender:) withSender:self];
    if (target) {
        [target setValue:value forCell:self sender:sender];
    }
}

@end
