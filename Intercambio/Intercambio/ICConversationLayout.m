//
//  ICConversationLayout.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 08.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationLayout.h"
#import "ICConversationChapterFragment.h"
#import "ICConversationFragment.h"
#import "ICConversationLayoutAttributes.h"
#import "ICConversationLayoutInvalidationContext.h"
#import "ICConversationMessageFragment.h"
#import "ICConversationParagraphFragment.h"
#import "ICConversationTimestampView.h"

NSString *const ICConversationLayoutTimestampDecorationKind = @"ICConversationLayoutTimestampDecorationKind";
NSString *const ICConversationLayoutElementKindAvatar = @"ICConversationLayoutElementKindAvatar";

@interface ICConversationLayout () {
    struct {
        BOOL dataSourceCountsAreValid : YES;
        BOOL layoutMetricsAreValid : YES;
        BOOL delegateSupportsPreferredSize;
        BOOL delegateSupportsDirection;
    } _flags;
    NSMutableArray *_invalidatedItemIndexPaths;

    ICConversationFragment *_previousMainFragment;
    ICConversationFragment *_mainFragment;
}

@end

@implementation ICConversationLayout

+ (Class)layoutAttributesClass
{
    return [ICConversationLayoutAttributes class];
}

+ (Class)invalidationContextClass
{
    return [ICConversationLayoutInvalidationContext class];
}

#pragma mark Life-cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _interitemSpacing = 10;

        [self registerClass:[ICConversationTimestampView class] forDecorationViewOfKind:ICConversationLayoutTimestampDecorationKind];
    }
    return self;
}

#pragma mark Providing Layout Attributes

- (void)prepareLayout
{
    id<UICollectionViewDelegateConversationLayout> delegate = (id<UICollectionViewDelegateConversationLayout>)self.collectionView.delegate;

    _flags.delegateSupportsPreferredSize = [delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:maxWidth:layoutMargins:)];

    _previousMainFragment = _mainFragment;

    if (_flags.dataSourceCountsAreValid == NO) {
        _mainFragment = [self generateMainFragment];
        _flags.layoutMetricsAreValid = NO;
        _flags.dataSourceCountsAreValid = YES;
    }

    if (_flags.layoutMetricsAreValid == NO || [_invalidatedItemIndexPaths count] > 0) {
        CGFloat lineHeight = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] lineHeight];
        CGPoint offset = CGPointMake(0, 0);
        CGFloat width = CGRectGetWidth(self.collectionView.bounds);
        [_mainFragment layoutFragmentWithOffset:offset
                                          width:width
                                       position:(ICConversationFragmentPositionFirst | ICConversationFragmentPositionLast)
                                   sizeCallback:^CGSize(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins) {
                                       if (_flags.delegateSupportsPreferredSize) {
                                           return [delegate collectionView:self.collectionView
                                                                    layout:self
                                                    sizeForItemAtIndexPath:indexPath
                                                                  maxWidth:width
                                                             layoutMargins:layoutMargins];
                                       } else {
                                           return CGSizeMake(width, lineHeight + layoutMargins.top + layoutMargins.bottom);
                                       }
                                   }];
        _flags.layoutMetricsAreValid = YES;
    }

    [super prepareLayout];
}

- (ICConversationFragment *)generateMainFragment
{
    __block NSDate *previousTimestamp = nil;
    __block id<ICConversationLayoutItem> previousItem = nil;

    __block NSDate *chapterTimestamp = nil;
    __block NSMutableArray *chapterFragments = [[NSMutableArray alloc] init];
    __block NSMutableArray *paragraphFragments = [[NSMutableArray alloc] init];
    __block NSMutableArray *messageFragments = [[NSMutableArray alloc] init];
    __block BOOL showAvatar = NO;
    __block ICConversationLayoutItemDirection direction = ICConversationLayoutItemDirectionUnknown;

    void (^completeParagraph)() = ^{
        if ([messageFragments count] > 0) {
            ICConversationParagraphFragment *paragraphFragment = [[ICConversationParagraphFragment alloc] initWithFragments:messageFragments];
            paragraphFragment.fragmentSpacing = 1;
            if (direction == ICConversationLayoutItemDirectionUnknown) {
                paragraphFragment.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                paragraphFragment.showAvatar = NO;
            } else {
                paragraphFragment.contentInsets = UIEdgeInsetsMake(0, 36, 0, 0);
                paragraphFragment.avatarSize = CGSizeMake(28, 28);
                paragraphFragment.showAvatar = showAvatar;
            }

            [paragraphFragments addObject:paragraphFragment];
            messageFragments = [[NSMutableArray alloc] init];
        }
    };

    void (^completeChapter)() = ^{
        completeParagraph();
        if ([paragraphFragments count] > 0) {
            ICConversationChapterFragment *chapterFragment = [[ICConversationChapterFragment alloc] initWithFragments:paragraphFragments
                                                                                                            timestamp:chapterTimestamp];
            chapterFragment.fragmentSpacing = 5;
            chapterFragment.contentInsets = UIEdgeInsetsMake(34, 0, 0, 0);
            [chapterFragments addObject:chapterFragment];
            paragraphFragments = [[NSMutableArray alloc] init];
            chapterTimestamp = nil;
        }
    };

    [self enumerateItemsWithBlock:^(id<ICConversationLayoutItem> item, NSDate *timestamp, NSIndexPath *indexPath) {

        BOOL startNewChapter = paragraphFragments == nil || (previousTimestamp != nil && timestamp != nil && fabs([previousTimestamp timeIntervalSinceDate:timestamp]) > 15 * 60);
        if (startNewChapter) {
            completeChapter();
        }

        BOOL startNewParagraph = messageFragments == nil || item == nil || previousItem == nil || ![previousItem isEqual:item];
        if (startNewParagraph) {
            completeParagraph();
        }

        if (chapterTimestamp == nil) {
            chapterTimestamp = timestamp;
        }

        showAvatar = [item direction] == ICConversationLayoutItemDirectionIn;
        direction = [item direction];

        ICConversationMessageFragment *messageFragment = [[ICConversationMessageFragment alloc] initWithIndexPath:indexPath];
        messageFragment.alignment = [self alinmentForDirection:item.direction];
        messageFragment.layoutMargins = self.itemLayoutMargins;
        [messageFragments addObject:messageFragment];

        previousItem = item;
        previousTimestamp = timestamp;
    }];

    completeChapter();

    ICConversationFragment *mainFragment = [[ICConversationFragment alloc] initWithFragments:chapterFragments];
    mainFragment.fragmentSpacing = 0;
    mainFragment.contentInsets = self.collectionView.layoutMargins;

    return mainFragment;
}

- (void)enumerateItemsWithBlock:(void (^)(id<ICConversationLayoutItem> item, NSDate *timestamp, NSIndexPath *indexPath))block
{
    NSUInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {

        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:sectionIndex];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            id<ICConversationLayoutItem> item = [self layoutItemAtIndexPath:indexPath];
            NSDate *timestamp = [self timestampAtIndexPath:indexPath];
            block(item, timestamp, indexPath);
        }
    }
}

- (id<ICConversationLayoutItem>)layoutItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDelegateConversationLayout> delegate = (id<UICollectionViewDelegateConversationLayout>)self.collectionView.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:layout:layoutItemOfItemAtIndexPath:)]) {
        return [delegate collectionView:self.collectionView layout:self layoutItemOfItemAtIndexPath:indexPath];
    }
    return nil;
}

- (NSDate *)timestampAtIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDelegateConversationLayout> delegate = (id<UICollectionViewDelegateConversationLayout>)self.collectionView.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:layout:timestampOfItemAtIndexPath:)]) {
        return [delegate collectionView:self.collectionView layout:self timestampOfItemAtIndexPath:indexPath];
    }
    return nil;
}

- (ICConversationFragmentAlignment)alinmentForDirection:(ICConversationLayoutItemDirection)direction
{
    switch (direction) {
    case ICConversationLayoutItemDirectionIn:
        return ICConversationFragmentAlignmentLeft;

    case ICConversationLayoutItemDirectionOut:
        return ICConversationFragmentAlignmentRight;

    default:
        return ICConversationFragmentAlignmentCenter;
    }
}

- (CGSize)collectionViewContentSize
{
    return _mainFragment.rect.size;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGFloat offset = CGRectGetHeight(_mainFragment.rect) - CGRectGetHeight(_previousMainFragment.rect);
    contentOffset.y += offset;
    return contentOffset;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [_mainFragment layoutAttributesForElementsInRect:rect];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_mainFragment layoutAttributesForItemAtIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [_mainFragment layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    return [_mainFragment layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    return [_mainFragment layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}

- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind
{
    return [_previousMainFragment indexPathsForSupplementaryViewOfKind:elementKind];
}

- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind
{
    return [_previousMainFragment indexPathsForDecorationViewOfKind:elementKind];
}

- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind
{
    return [_mainFragment indexPathsForSupplementaryViewOfKind:elementKind];
}

- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind
{
    return [_mainFragment indexPathsForDecorationViewOfKind:elementKind];
}

#pragma mark Invalidating the Layout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return CGRectGetWidth(self.collectionView.bounds) != CGRectGetWidth(newBounds);
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    ICConversationLayoutInvalidationContext *context = (ICConversationLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    context.invalidateLayoutMetrics = YES;
    return context;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)ctx
{
    if (_invalidatedItemIndexPaths == nil) {
        _invalidatedItemIndexPaths = [[NSMutableArray alloc] init];
    }

    ICConversationLayoutInvalidationContext *context = (ICConversationLayoutInvalidationContext *)ctx;

    if (context.invalidateEverything || context.invalidateDataSourceCounts) {
        _flags.dataSourceCountsAreValid = NO; // Will invalidate everything
    } else if (context.invalidateLayoutMetrics) {
        _flags.layoutMetricsAreValid = NO;
    } else {
        if (context.invalidatedItemIndexPaths) {
            [_invalidatedItemIndexPaths addObjectsFromArray:context.invalidatedItemIndexPaths];
        }
    }

    [super invalidateLayoutWithContext:context];
}

@end
