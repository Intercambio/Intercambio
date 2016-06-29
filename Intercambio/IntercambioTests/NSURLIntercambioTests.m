//
//  NSURLIntercambioTests.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "NSURL+Intercambio.h"
#import <XCTest/XCTest.h>

@interface NSURLIntercambioTests : XCTestCase

@end

@implementation NSURLIntercambioTests

- (void)testXMPPNodeComponent
{
    XCTAssertTrue([[NSURL URLWithString:@"xmpp:foo@example.com"] hasXMPPNodeComponent]);
    XCTAssertTrue([[NSURL URLWithString:@"xmpp:///foo@example.com"] hasXMPPNodeComponent]);
    XCTAssertTrue([[NSURL URLWithString:@"xmpp:///foo@example.com/Resource"] hasXMPPNodeComponent]);
    XCTAssertTrue([[NSURL URLWithString:@"xmpp://bar@example.com/foo@example.com"] hasXMPPNodeComponent]);

    XCTAssertFalse([[NSURL URLWithString:@"xmpp://foo@example.com"] hasXMPPNodeComponent]);
    XCTAssertFalse([[NSURL URLWithString:@"xmpp:"] hasXMPPNodeComponent]);
}

- (void)testXMPPAuthorityComponent
{
    XCTAssertTrue([[NSURL URLWithString:@"xmpp://foo@example.com"] hasXMPPAuthorityComponent]);
    XCTAssertTrue([[NSURL URLWithString:@"xmpp://bar@example.com/foo@example.com"] hasXMPPAuthorityComponent]);

    XCTAssertFalse([[NSURL URLWithString:@"xmpp:"] hasXMPPAuthorityComponent]);
}

- (void)testURLWithAcountURI
{
    NSURL *URL = [NSURL URLWithString:@"xmpp:///foo@example.com"];
    NSURL *newURL = [URL URLWithAcountURI:[NSURL URLWithString:@"xmpp://bar@example.com"]];
    XCTAssertEqualObjects(newURL, [NSURL URLWithString:@"xmpp://bar@example.com/foo@example.com"]);
}

@end
