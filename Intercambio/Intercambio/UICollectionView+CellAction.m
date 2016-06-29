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

@end
