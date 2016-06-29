//
//  ICRecentConversationsViewController.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICRecentConversationsUserInterface.h"
#import <Fountain/Fountain.h>
#import <UIKit/UIKit.h>

@interface ICRecentConversationsViewController : UITableViewController <ICRecentConversationsUserInterface>

#pragma mark Data Source
@property (nonatomic, strong) id<FTDataSource> dataSource;

@end
