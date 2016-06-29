//
//  ICConversationFragment.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICConversationFragmentAlignment) {
    ICConversationFragmentAlignmentCenter,
    ICConversationFragmentAlignmentLeft,
    ICConversationFragmentAlignmentRight
};

typedef NS_OPTIONS(NSUInteger, ICConversationFragmentPosition) {
    ICConversationFragmentPositionNone = 0,
    ICConversationFragmentPositionFirst = 1 << 0,
    ICConversationFragmentPositionLast = 1 << 1,
};

typedef CGSize (^ICConversationFragmentSizeCallback)(NSIndexPath *indexPath, CGFloat width, UIEdgeInsets layoutMargins);

@interface ICConversationFragment : NSObject

#pragma mark Life-cycle
- (instancetype)initWithFragments:(NSArray *)fragments;

#pragma mark Child Fragments
@property (nonatomic, readonly) NSArray *fragments;
@property (nonatomic, assign) CGFloat fragmentSpacing;

#pragma mark Index Path
@property (nonatomic, readonly) NSIndexPath *firstIndexPath;
@property (nonatomic, readonly) NSIndexPath *lastIndexPath;

#pragma mark Metrics
@property (nonatomic, assign) UIEdgeInsets contentInsets;

#pragma mark Layout
- (void)layoutFragmentWithOffset:(CGPoint)offset
                           width:(CGFloat)width
                        position:(ICConversationFragmentPosition)position
                    sizeCallback:(ICConversationFragmentSizeCallback)sizeCallback;

#pragma mark Rect
@property (nonatomic, readonly) CGRect rect;

#pragma mark Layout Attributes
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath;

- (NSArray<NSIndexPath *> *)indexPathsForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsForDecorationViewOfKind:(NSString *)elementKind;

@end
