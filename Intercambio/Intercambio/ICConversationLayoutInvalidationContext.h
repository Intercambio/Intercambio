//
//  ICConversationLayoutInvalidationContext.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 12.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICConversationLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic, assign) BOOL invalidateLayoutMetrics;

@end
