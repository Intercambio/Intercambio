//
//  UICollectionView+CellAction.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.04.16.
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


#import "UICollectionView+CellAction.h"

@implementation UICollectionView (CellAction)

- (void)performAction:(SEL)action forCell:(UICollectionViewCell *)cell sender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        if (indexPath) {
            [self.delegate collectionView:self performAction:action forItemAtIndexPath:indexPath withSender:sender];
        }
    }
}

- (void)handleControlEvents:(UIControlEvents)controlEvents forCell:(nonnull UICollectionViewCell *)cell sender:(nullable id)sender
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath) {
        if ([self.delegate conformsToProtocol:@protocol(UICollectionViewDelegateAction)]) {
            id<UICollectionViewDelegateAction> delegate = (id<UICollectionViewDelegateAction>)self.delegate;
            if ([delegate respondsToSelector:@selector(collectionView:handleControlEvents:forItemAtIndexPath:sender:)]) {
                [delegate collectionView:self handleControlEvents:controlEvents forItemAtIndexPath:indexPath sender:sender];
            }
        }
    }
}

@end

@implementation UICollectionViewCell (CellAction)

- (void)performAction:(nonnull SEL)action sender:(nullable id)sender
{
    id target = [self targetForAction:@selector(performAction:forCell:sender:) withSender:self];
    if (target) {
        [target performAction:action forCell:self sender:sender];
    }
}

- (void)handleControlEvents:(UIControlEvents)controlEvents sender:(id)sender
{
    id target = [self targetForAction:@selector(handleControlEvents:forCell:sender:) withSender:self];
    if (target) {
        [target handleControlEvents:controlEvents forCell:self sender:sender];
    }
}

@end
