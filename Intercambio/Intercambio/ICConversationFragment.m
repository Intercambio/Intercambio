//
//  ICConversationFragment.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationFragment.h"

@interface ICConversationFragment () {
    CGRect _childFragmentsRect;
}

@end

@implementation ICConversationFragment

#pragma mark Life-cycle

- (instancetype)initWithFragments:(NSArray *)fragments
{
    self = [super init];
    if (self) {
        _fragments = fragments;
    }
    return self;
}

#pragma mark Index Path

- (NSIndexPath *)firstIndexPath
{
    return [[self.fragments firstObject] firstIndexPath];
}

- (NSIndexPath *)lastIndexPath
{
    return [[self.fragments lastObject] lastIndexPath];
}

#pragma mark Layout Fragment

- (void)layoutFragmentWithOffset:(CGPoint)offset width:(CGFloat)width position:(ICConversationFragmentPosition)position sizeCallback:(ICConversationFragmentSizeCallback)sizeCallback
{
    CGPoint currectOffset = offset;
    currectOffset.x += self.contentInsets.left;
    currectOffset.y += self.contentInsets.top;

    CGFloat contentWidth = width - (self.contentInsets.left + self.contentInsets.right);

    for (ICConversationFragment *fragment in self.fragments) {

        ICConversationFragmentPosition position = [self positionOfChildFragment:fragment];

        [fragment layoutFragmentWithOffset:currectOffset
                                     width:contentWidth
                                  position:position
                              sizeCallback:sizeCallback];

        currectOffset.y = CGRectGetMaxY(fragment.rect);

        if (fragment != [self.fragments lastObject]) {
            currectOffset.y += self.fragmentSpacing;
        }
    }

    currectOffset.y += self.contentInsets.bottom;

    _childFragmentsRect = CGRectMake(offset.x, offset.y, width, currectOffset.y - offset.y);
}

- (ICConversationFragmentPosition)positionOfChildFragment:(ICConversationFragment *)fragment
{
    if (fragment == [self.fragments firstObject] && fragment == [self.fragments lastObject]) {
        return ICConversationFragmentPositionFirst | ICConversationFragmentPositionLast;
    } else if (fragment == [self.fragments firstObject]) {
        return ICConversationFragmentPositionFirst;
    } else if (fragment == [self.fragments lastObject]) {
        return ICConversationFragmentPositionLast;
    } else {
        return ICConversationFragmentPositionNone;
    }
}

#pragma mark Rect

- (CGRect)rect
{
    return _childFragmentsRect;
}

#pragma mark Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    if (CGRectIntersectsRect(self.rect, rect)) {
        for (ICConversationFragment *fragment in self.fragments) {
            [attributes addObjectsFromArray:[fragment layoutAttributesForElementsInRect:rect]];
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = nil;
    for (ICConversationFragment *fragment in self.fragments) {
        attributes = [fragment layoutAttributesForItemAtIndexPath:indexPath];
        if (attributes) {
            break;
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = nil;
    for (ICConversationFragment *fragment in self.fragments) {
        attributes = [fragment layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
        if (attributes) {
            break;
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = nil;
    for (ICConversationFragment *fragment in self.fragments) {
        attributes = [fragment layoutAttributesForDecorationViewOfKind:decorationViewKind atIndexPath:indexPath];
        if (attributes) {
            break;
        }
    }
    return attributes;
}

- (NSArray<NSIndexPath *> *)indexPathsForSupplementaryViewOfKind:(NSString *)elementKind
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (ICConversationFragment *fragment in self.fragments) {
        [indexPaths addObjectsFromArray:[fragment indexPathsForSupplementaryViewOfKind:elementKind]];
    }
    return indexPaths;
}

- (NSArray<NSIndexPath *> *)indexPathsForDecorationViewOfKind:(NSString *)elementKind
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (ICConversationFragment *fragment in self.fragments) {
        [indexPaths addObjectsFromArray:[fragment indexPathsForDecorationViewOfKind:elementKind]];
    }
    return indexPaths;
}

@end
