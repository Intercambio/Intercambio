//
//  ICConversationLayout.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 08.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICConversationLayoutAttributes.h"

extern NSString *const ICConversationLayoutTimestampDecorationKind;
extern NSString *const ICConversationLayoutElementKindAvatar;

typedef NS_ENUM(NSInteger, ICConversationLayoutItemDirection) {
    ICConversationLayoutItemDirectionUnknown,
    ICConversationLayoutItemDirectionIn,
    ICConversationLayoutItemDirectionOut
};

@protocol ICConversationLayoutItem <NSObject>
@property (nonatomic, readonly) id<NSObject> originIdentifier;
@property (nonatomic, readonly) id<NSObject> typeIdentifier;
@property (nonatomic, readonly) ICConversationLayoutItemDirection direction;
@property (nonatomic, readonly, getter=isTemporary) BOOL temporary;
@end

@protocol UICollectionViewDelegateConversationLayout <UICollectionViewDelegate>
@optional

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
                  maxWidth:(CGFloat)maxWidth
             layoutMargins:(UIEdgeInsets)layoutMargins;

- (id<ICConversationLayoutItem>)collectionView:(UICollectionView *)collectionView
                                        layout:(UICollectionViewLayout *)collectionViewLayout
                   layoutItemOfItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSDate *)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
    timestampOfItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ICConversationLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) UIEdgeInsets itemLayoutMargins;

@end
