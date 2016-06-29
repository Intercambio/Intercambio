//
//  ICNewConversationViewController.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationUserInterface.h"
#import <Fountain/Fountain.h>
#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICConversationViewController : UICollectionViewController <ICConversationUserInterface>

@property (nonatomic, strong) id<ICDataSourceProvider> dataSourceProvider;
@property (nonatomic, strong) id<FTDataSource, FTReverseDataSource> accountDataSource;
@property (nonatomic, strong) id<ICConversationProvider> conversationProvider;

@end
