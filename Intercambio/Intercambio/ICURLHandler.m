//
//  ICURLHandler.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICURLHandler.h"
#import "NSURL+Intercambio.h"

@implementation ICURLHandler

#pragma mark Life-cycle

- (instancetype)initWithWireframe:(Wireframe *)wireframe
{
    self = [super init];
    if (self) {
        _wireframe = wireframe;
    }
    return self;
}

#pragma mark Handle URL

- (BOOL)handleURL:(NSURL *)URL
{
    if ([URL hasXMPPNodeComponent]) {
        [self.wireframe presentConversationFor:URL];
        return YES;
    }
    return NO;
}

@end
