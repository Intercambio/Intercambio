//
//  NSURL+Intercambio.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "NSURL+Intercambio.h"

@implementation NSURL (Intercambio)

- (BOOL)hasXMPPAuthorityComponent
{
    return [self.scheme isEqualToString:@"xmpp"] && self.user != nil && self.host != nil;
}

- (BOOL)hasXMPPNodeComponent
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    NSArray *pathComponents = [[components.path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != \"\""]];
    return [self.scheme isEqualToString:@"xmpp"] && [pathComponents count] > 0;
}

- (NSURL *)URLWithAcountURI:(NSURL *)accountURI
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    NSURLComponents *accountURIComponents = [[NSURLComponents alloc] initWithURL:accountURI resolvingAgainstBaseURL:YES];
    if (accountURIComponents.user && accountURIComponents.host) {
        components.user = accountURIComponents.user;
        components.host = accountURIComponents.host;
        return [components URL];
    } else {
        return nil;
    }
}

- (NSURL *)accountURI
{
    if ([self hasXMPPAuthorityComponent]) {
        NSURLComponents *components = [[NSURLComponents alloc] init];
        components.scheme = @"xmpp";
        components.user = self.user;
        components.host = self.host;
        return [components URL];
    } else {
        return nil;
    }
}

@end
