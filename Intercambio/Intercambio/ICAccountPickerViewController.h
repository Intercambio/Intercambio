//
//  ICAccountPickerViewController.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 14.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <Fountain/Fountain.h>
#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@class ICAccountPickerViewController;

@protocol ICAccountPickerViewControllerDelegate <NSObject>
@optional
- (void)accountPicker:(ICAccountPickerViewController *)accountPicker didPickAccount:(id<ICAccountViewModel>)account;
- (void)accountPickerDidCancel:(ICAccountPickerViewController *)accountPicker;
@end

@interface ICAccountPickerViewController : UITableViewController

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) id<FTDataSource, FTReverseDataSource> dataSource;
@property (nonatomic, strong) id<ICAccountViewModel> selectedAccount;

@end
