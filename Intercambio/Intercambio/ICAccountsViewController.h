//
//  ICAccountsViewController.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 16.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountsUserInterface.h"
#import <Fountain/Fountain.h>
#import <UIKit/UIKit.h>

@interface ICAccountsViewController : UITableViewController <ICAccountsUserInterface>

#pragma mark Data Source
@property (nonatomic, strong) id<FTDataSource> dataSource;

@end
