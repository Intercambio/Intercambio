//
//  ICConversationMessageFragment.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationMessageFragment.h"
#import "ICConversationLayoutAttributes.h"

@interface ICConversationMessageFragment () {
    NSIndexPath *_indexPath;
    CGFloat _maxWidth;
    CGRect _rect;
    UICollectionViewLayoutAttributes *_attributes;
}

@end

@implementation ICConversationMessageFragment

#pragma mark Life-cycle

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        _indexPath = indexPath;
        _rect = CGRectNull;
        _layoutMargins = UIEdgeInsetsMake(4, 4, 4, 4);
    }
    return self;
}

#pragma mark Index Path

- (NSIndexPath *)firstIndexPath
{
    return _indexPath;
}

- (NSIndexPath *)lastIndexPath
{
    return _indexPath;
}

#pragma mark Layout Fragment

- (void)layoutFragmentWithOffset:(CGPoint)offset width:(CGFloat)width position:(ICConversationFragmentPosition)position sizeCallback:(ICConversationFragmentSizeCallback)sizeCallback
{
    [self updateRectWithOffset:offset width:width sizeCallback:sizeCallback];
    [self updateLayoutAttributesWithPosition:position];
}

- (void)updateRectWithOffset:(CGPoint)offset width:(CGFloat)width sizeCallback:(ICConversationFragmentSizeCallback)sizeCallback
{
    CGFloat minPadding = 48.0;
    CGFloat maxReadableWidth = 320.0;
    _maxWidth = fmin(maxReadableWidth, width - minPadding);

    CGSize size = sizeCallback(_indexPath, _maxWidth, _layoutMargins);
    size.width = fmin(size.width, width);

    CGRect rect;
    rect.size = size;

    switch (_alignment) {
    case ICConversationFragmentAlignmentLeft:
        rect.origin = offset;
        break;

    case ICConversationFragmentAlignmentRight:
        rect.origin = CGPointMake(offset.x + (width - size.width), offset.y);
        break;

    default:
        rect.origin = CGPointMake(offset.x + 0.5 * (width - size.width), offset.y);
        break;
    }

    _rect = rect;
}

- (void)updateLayoutAttributesWithPosition:(ICConversationFragmentPosition)position
{
    ICConversationLayoutAttributes *attributes = [ICConversationLayoutAttributes layoutAttributesForCellWithIndexPath:_indexPath];
    attributes.frame = _rect;
    attributes.alignment = self.alignment;
    attributes.first = position & ICConversationFragmentPositionFirst;
    attributes.last = position & ICConversationFragmentPositionLast;
    attributes.layoutMargins = self.layoutMargins;
    attributes.maxWidth = _maxWidth;
    _attributes = attributes;
}

#pragma mark Rect

- (CGRect)rect
{
    return _rect;
}

#pragma mark Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if (CGRectIntersectsRect(rect, _rect)) {
        return @[ _attributes ];
    } else {
        return @[];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_indexPath isEqual:indexPath]) {
        return _attributes;
    } else {
        return nil;
    }
}

@end
