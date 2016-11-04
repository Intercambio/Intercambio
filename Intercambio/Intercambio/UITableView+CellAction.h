//
//  UITableView+CellAction.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewDelegateCellAction <UITableViewDelegate>
@optional
- (void)tableView:(nonnull UITableView *)tableView setValue:(nullable id)value forRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end

@interface UITableView (CellAction)
- (void)performAction:(nonnull SEL)action forCell:(nonnull UITableViewCell *)cell sender:(nullable id)sender;
- (void)setValue:(nullable id)value forCell:(nonnull UITableViewCell *)cell sender:(nullable id)sender;
@end

@interface UITableViewCell (CellAction)
- (void)performAction:(nonnull SEL)action sender:(nullable id)sender;
- (void)setValue:(nullable id)value sender:(nullable id)sender;
@end
