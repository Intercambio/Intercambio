//
//  UITableView+CellAction.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
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
