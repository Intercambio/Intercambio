//
//  ICConversationMessageFragmentTests.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ICConversationLayoutAttributes.h"
#import "ICConversationMessageFragment.h"

@interface ICConversationMessageFragmentTests : XCTestCase

@end

@implementation ICConversationMessageFragmentTests

- (void)testLeftAlinment
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:4];
    ICConversationMessageFragment *fragment = [[ICConversationMessageFragment alloc] initWithIndexPath:indexPath];

    fragment.alignment = ICConversationFragmentAlignmentLeft;

    CGPoint offset = CGPointMake(12, 6);
    CGFloat width = 230;

    [fragment layoutFragmentWithOffset:offset
                                 width:width
                              position:ICConversationFragmentPositionNone
                          sizeCallback:^CGSize(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins) {
                              return CGSizeMake(120, 36);
                          }];

    XCTAssertFalse(CGRectIsNull(fragment.rect));
    XCTAssertTrue(CGRectEqualToRect(fragment.rect, CGRectMake(offset.x, offset.y, 120, 36)));

    UICollectionViewLayoutAttributes *attributes = [fragment layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertNotNil(attributes);

    XCTAssertTrue(CGRectEqualToRect(attributes.frame, CGRectMake(offset.x, offset.y, 120, 36)));
    XCTAssertEqualObjects(attributes.indexPath, indexPath);

    XCTAssertTrue([attributes isKindOfClass:[ICConversationLayoutAttributes class]]);

    ICConversationLayoutAttributes *messageAttributes = (ICConversationLayoutAttributes *)attributes;
    XCTAssertEqual(messageAttributes.alignment, ICConversationFragmentAlignmentLeft);
}

- (void)testRightAlinment
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:4];
    ICConversationMessageFragment *fragment = [[ICConversationMessageFragment alloc] initWithIndexPath:indexPath];

    fragment.alignment = ICConversationFragmentAlignmentRight;

    CGPoint offset = CGPointMake(12, 6);
    CGFloat width = 230;

    [fragment layoutFragmentWithOffset:offset
                                 width:width
                              position:ICConversationFragmentPositionNone
                          sizeCallback:^CGSize(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins) {
                              return CGSizeMake(120, 36);
                          }];

    XCTAssertFalse(CGRectIsNull(fragment.rect));
    XCTAssertTrue(CGRectEqualToRect(fragment.rect, CGRectMake(offset.x + 110, offset.y, 120, 36)));

    UICollectionViewLayoutAttributes *attributes = [fragment layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertNotNil(attributes);

    XCTAssertTrue(CGRectEqualToRect(attributes.frame, CGRectMake(offset.x + 110, offset.y, 120, 36)));
    XCTAssertEqualObjects(attributes.indexPath, indexPath);

    XCTAssertTrue([attributes isKindOfClass:[ICConversationLayoutAttributes class]]);

    ICConversationLayoutAttributes *messageAttributes = (ICConversationLayoutAttributes *)attributes;
    XCTAssertEqual(messageAttributes.alignment, ICConversationFragmentAlignmentRight);
}

- (void)testFirst
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:4];
    ICConversationMessageFragment *fragment = [[ICConversationMessageFragment alloc] initWithIndexPath:indexPath];

    fragment.alignment = ICConversationFragmentAlignmentRight;

    CGPoint offset = CGPointMake(12, 6);
    CGFloat width = 230;

    [fragment layoutFragmentWithOffset:offset
                                 width:width
                              position:ICConversationFragmentPositionFirst
                          sizeCallback:^CGSize(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins) {
                              return CGSizeMake(120, 36);
                          }];

    ICConversationLayoutAttributes *attributes = (ICConversationLayoutAttributes *)[fragment layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertTrue([attributes isKindOfClass:[ICConversationLayoutAttributes class]]);
    XCTAssertTrue(attributes.first);
    XCTAssertFalse(attributes.last);
}

- (void)testLast
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:4];
    ICConversationMessageFragment *fragment = [[ICConversationMessageFragment alloc] initWithIndexPath:indexPath];

    fragment.alignment = ICConversationFragmentAlignmentRight;

    CGPoint offset = CGPointMake(12, 6);
    CGFloat width = 230;

    [fragment layoutFragmentWithOffset:offset
                                 width:width
                              position:ICConversationFragmentPositionLast
                          sizeCallback:^CGSize(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins) {
                              return CGSizeMake(120, 36);
                          }];

    ICConversationLayoutAttributes *attributes = (ICConversationLayoutAttributes *)[fragment layoutAttributesForItemAtIndexPath:indexPath];
    XCTAssertTrue([attributes isKindOfClass:[ICConversationLayoutAttributes class]]);
    XCTAssertFalse(attributes.first);
    XCTAssertTrue(attributes.last);
}

@end
