//
//  ICAccountOptionsViewController.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 22.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICAccountOptionsViewController : UITableViewController

@property (nonatomic, strong) id<ICAccountViewModel> account;

@end
