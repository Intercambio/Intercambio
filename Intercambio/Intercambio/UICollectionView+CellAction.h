//
//  UICollectionView+CellAction.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICollectionViewDelegateAction <UICollectionViewDelegate>
@optional
- (void)collectionView:(nonnull UICollectionView *)collectionView handleControlEvents:(UIControlEvents)controlEvents forItemAtIndexPath:(nonnull NSIndexPath *)indexPath sender:(nullable id)sender;
@end

@interface UICollectionView (CellAction)
- (void)performAction:(nonnull SEL)action forCell:(nonnull UICollectionViewCell *)cell sender:(nullable id)sender;
- (void)handleControlEvents:(UIControlEvents)controlEvents forCell:(nonnull UICollectionViewCell *)cell sender:(nullable id)sender;
@end

@interface UICollectionViewCell (CellAction)
- (void)performAction:(nonnull SEL)action sender:(nullable id)sender;
- (void)handleControlEvents:(UIControlEvents)controlEvents sender:(nullable id)sender;
@end
