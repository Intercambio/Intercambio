//
//  ICConversationFragmentTests.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ICConversationLayoutAttributes.h"
#import "ICConversationMessageFragment.h"

@interface ICConversationFragmentTests : XCTestCase

@end

@implementation ICConversationFragmentTests

- (void)testLayoutChildFragments
{
    NSMutableArray *fragments = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < 3; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:4];
        ICConversationMessageFragment *fragment = [[ICConversationMessageFragment alloc] initWithIndexPath:indexPath];
        fragment.alignment = ICConversationFragmentAlignmentLeft;
        [fragments addObject:fragment];
    }

    ICConversationFragment *fragment = [[ICConversationFragment alloc] initWithFragments:fragments];
    fragment.fragmentSpacing = 1;

    CGPoint offset = CGPointMake(12, 6);
    CGFloat width = 230;

    [fragment layoutFragmentWithOffset:offset
                                 width:width
                              position:(ICConversationFragmentPositionFirst | ICConversationFragmentPositionLast)
                          sizeCallback:^CGSize(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins) {
                              return CGSizeMake(120, 36);
                          }];

    CGRect expectedRect = CGRectMake(12, 6, 230, 3 * 36 + 2 * 1);
    XCTAssertTrue(CGRectEqualToRect(fragment.rect, expectedRect));

    ICConversationLayoutAttributes *attributes = nil;

    attributes = (ICConversationLayoutAttributes *)[fragment layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:4]];
    XCTAssertTrue(attributes.first);
    XCTAssertFalse(attributes.last);

    attributes = (ICConversationLayoutAttributes *)[fragment layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:4]];
    XCTAssertFalse(attributes.first);
    XCTAssertFalse(attributes.last);

    attributes = (ICConversationLayoutAttributes *)[fragment layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:4]];
    XCTAssertFalse(attributes.first);
    XCTAssertTrue(attributes.last);
}

@end
