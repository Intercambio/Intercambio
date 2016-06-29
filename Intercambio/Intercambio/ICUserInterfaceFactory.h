//
//  ICUserInterfaceFactory.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAppWireframe.h"
#import <Foundation/Foundation.h>
#import <IntercambioCore/IntercambioCore.h>

@interface ICUserInterfaceFactory : NSObject <ICAppWireframeDelegate>

#pragma mark Life-cycle
- (instancetype)initWithCommunicationService:(ICCommunicationService *)communicationService;

#pragma mark Properties
@property (nonatomic, readonly) ICCommunicationService *communicationService;

@end
