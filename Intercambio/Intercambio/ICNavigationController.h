//
//  ICNavigationController.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICUserInterface.h"
#import <Fountain/Fountain.h>
#import <UIKit/UIKit.h>

@interface ICNavigationController : UINavigationController <ICUserInterface>

#pragma mark Life-cycle
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

#pragma mark Data Source
@property (nonatomic, strong) id<FTDataSource> accountDataSource;

#pragma mark Connection Status
@property (nonatomic, assign) BOOL showConnectionStatus;

@end
