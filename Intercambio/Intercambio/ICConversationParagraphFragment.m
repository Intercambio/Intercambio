//
//  ICConversationParagraphFragment.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationParagraphFragment.h"
#import "ICConversationLayout.h"

@interface ICConversationParagraphFragment () {
    NSArray *_supplementaryViewLayoutAttributes;
}

@end

@implementation ICConversationParagraphFragment

#pragma mark Layout Fragment

- (void)layoutFragmentWithOffset:(CGPoint)offset width:(CGFloat)width position:(ICConversationFragmentPosition)position sizeCallback:(ICConversationFragmentSizeCallback)sizeCallback
{
    [super layoutFragmentWithOffset:offset width:width position:position sizeCallback:sizeCallback];
    [self updateSupplementaryViewLayoutAttributesWithOffset:offset];
}

- (void)updateSupplementaryViewLayoutAttributesWithOffset:(CGPoint)offset
{
    NSMutableArray *avatarAttributes = [[NSMutableArray alloc] init];
    if (_showAvatar) {
        ICConversationFragment *fragment = [self.fragments firstObject];
        if (fragment) {
            CGFloat offsetY = CGRectGetMaxY([[self.fragments lastObject] rect]) - self.avatarSize.height;
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ICConversationLayoutElementKindAvatar
                                                                                                                          withIndexPath:fragment.firstIndexPath];
            attributes.frame = CGRectMake(offset.x, offsetY, self.avatarSize.width, self.avatarSize.height);
            attributes.zIndex = -1;
            [avatarAttributes addObject:attributes];
        }
    }
    _supplementaryViewLayoutAttributes = avatarAttributes;
}

#pragma mark Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *result = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    for (UICollectionViewLayoutAttributes *attributes in _supplementaryViewLayoutAttributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [result addObject:attributes];
        }
    }
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    for (UICollectionViewLayoutAttributes *attributes in _supplementaryViewLayoutAttributes) {
        if ([attributes.representedElementKind isEqualToString:kind] && [attributes.indexPath isEqual:indexPath]) {
            return attributes;
        }
    }
    return [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
}

- (NSArray<NSIndexPath *> *)indexPathsForSupplementaryViewOfKind:(NSString *)elementKind
{
    NSMutableArray *indexPaths = [[super indexPathsForSupplementaryViewOfKind:elementKind] mutableCopy];
    for (UICollectionViewLayoutAttributes *attributes in _supplementaryViewLayoutAttributes) {
        if ([attributes.representedElementKind isEqualToString:elementKind]) {
            [indexPaths addObject:attributes.indexPath];
        }
    }
    return indexPaths;
}

@end
