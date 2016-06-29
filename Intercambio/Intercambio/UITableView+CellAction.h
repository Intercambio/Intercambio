//
//  UITableView+CellAction.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (CellAction)

- (void)performAction:(SEL)action forCell:(UITableViewCell *)cell sender:(id)sender;

@end
