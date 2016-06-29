//
//  NSURL+Intercambio.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Intercambio)

- (BOOL)hasXMPPAuthorityComponent;
- (BOOL)hasXMPPNodeComponent;

- (NSURL *)URLWithAcountURI:(NSURL *)accountURI;
- (NSURL *)accountURI;

@end
