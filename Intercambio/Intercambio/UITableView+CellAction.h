//
//  UITableView+CellAction.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (CellAction)
- (void)performAction:(nonnull SEL)action forCell:(nonnull UITableViewCell *)cell sender:(nullable id)sender;
@end
