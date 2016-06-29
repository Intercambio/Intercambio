//
//  ICConversationChapterFragment.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationChapterFragment.h"
#import "ICConversationLayout.h"
#import "ICConversationLayoutAttributes.h"

@interface ICConversationChapterFragment () {
    ICConversationLayoutTimestampAttributes *_headerAttributes;
}

@end

@implementation ICConversationChapterFragment

#pragma mark Life-cycle

- (instancetype)initWithFragments:(NSArray *)fragments timestamp:(NSDate *)timestamp
{
    self = [super initWithFragments:fragments];
    if (self) {
        _timestamp = timestamp;
    }
    return self;
}

#pragma mark Layout Fragment

- (void)layoutFragmentWithOffset:(CGPoint)offset width:(CGFloat)width position:(ICConversationFragmentPosition)position sizeCallback:(ICConversationFragmentSizeCallback)sizeCallback
{
    [super layoutFragmentWithOffset:offset width:width position:position sizeCallback:sizeCallback];
    [self updateHeaderAttributesWithOffset:offset width:width];
}

- (void)updateHeaderAttributesWithOffset:(CGPoint)offset width:(CGFloat)width
{
    _headerAttributes = [ICConversationLayoutTimestampAttributes layoutAttributesForDecorationViewOfKind:ICConversationLayoutTimestampDecorationKind withIndexPath:self.firstIndexPath];
    _headerAttributes.frame = CGRectMake(offset.x, offset.y, width, self.contentInsets.top);
    _headerAttributes.zIndex = -1;
    _headerAttributes.timestamp = _timestamp;
}

#pragma mark Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    if (CGRectIntersectsRect(_headerAttributes.frame, rect)) {
        [attributes addObject:_headerAttributes];
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    if (_headerAttributes && [decorationViewKind isEqualToString:ICConversationLayoutTimestampDecorationKind] && [indexPath isEqual:self.firstIndexPath]) {
        return _headerAttributes;
    } else {
        return [super layoutAttributesForDecorationViewOfKind:decorationViewKind atIndexPath:indexPath];
    }
}

- (NSArray<NSIndexPath *> *)indexPathsForDecorationViewOfKind:(NSString *)elementKind
{
    NSMutableArray *indexPaths = [[super indexPathsForDecorationViewOfKind:elementKind] mutableCopy];
    if (_headerAttributes && [elementKind isEqualToString:ICConversationLayoutTimestampDecorationKind]) {
        [indexPaths addObject:_headerAttributes.indexPath];
    }
    return indexPaths;
}

@end
