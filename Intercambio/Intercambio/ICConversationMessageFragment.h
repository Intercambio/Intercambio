//
//  ICConversationMessageFragment.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationFragment.h"

@interface ICConversationMessageFragment : ICConversationFragment

#pragma mark Life-cycle
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath;

#pragma mark Metrics
@property (nonatomic, assign) ICConversationFragmentAlignment alignment;
@property (nonatomic, assign) UIEdgeInsets layoutMargins;

@end
