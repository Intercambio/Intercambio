//
//  ICAccountSettingsViewController.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 20.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountSettingsUserInterface.h"
#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICAccountSettingsViewController : UITableViewController <ICAccountSettingsUserInterface>

@property (nonatomic, strong) id<ICAccountProvider> accountProvider;

@end
