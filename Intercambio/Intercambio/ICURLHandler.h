//
//  ICURLHandler.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

@import Foundation;
#import "ICAppWireframe.h"
#import <IntercambioCore/IntercambioCore.h>

@interface ICURLHandler : NSObject

#pragma mark Life-cycle
- (instancetype)initWithWireframe:(Wireframe *)appWireframe;

#pragma mark Properties
@property (nonatomic, readonly) Wireframe *wireframe;

#pragma mark Handle URL
- (BOOL)handleURL:(NSURL *)URL;

@end
