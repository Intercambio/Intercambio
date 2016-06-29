//
//  ICAccountSettingsUserInterface.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICUserInterface.h"

@protocol ICAccountSettingsUserInterface <ICUserInterface>

@property (nonatomic, strong) NSURL *accountURI;

@end
