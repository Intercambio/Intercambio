//
//  UICollectionView+CellAction.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
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

- (void)handleControlEvents:(UIControlEvents)controlEvents forCell:(nonnull UICollectionViewCell *)cell sender:(nullable id)sender {
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

- (void)performAction:(nonnull SEL)action sender:(nullable id)sender {
    id target = [self targetForAction:@selector(performAction:forCell:sender:) withSender:self];
    if (target) {
        [target performAction:action forCell:self sender:sender];
    }
}

- (void)handleControlEvents:(UIControlEvents)controlEvents sender:(id)sender {
    id target = [self targetForAction:@selector(handleControlEvents:forCell:sender:) withSender:self];
    if (target) {
        [target handleControlEvents:controlEvents forCell:self sender:sender];
    }
}

@end
