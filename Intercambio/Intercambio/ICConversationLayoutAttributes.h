//
//  ICConversationLayoutAttributes.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 09.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICConversationFragment.h"

@interface ICConversationLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, assign) ICConversationFragmentAlignment alignment;
@property (nonatomic, assign, getter=isFirst) BOOL first;
@property (nonatomic, assign, getter=isLast) BOOL last;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) UIEdgeInsets layoutMargins;
@end

@interface ICConversationLayoutTimestampAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong) NSDate *timestamp;
@end
