//
//  UICollectionView+CellAction.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (CellAction)

- (void)performAction:(SEL)action forCell:(UICollectionViewCell *)cell sender:(id)sender;

@end
