//
//  ICConversationChapterFragment.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationFragment.h"

@interface ICConversationChapterFragment : ICConversationFragment

#pragma mark Life-cycle
- (instancetype)initWithFragments:(NSArray *)fragments timestamp:(NSDate *)timestamp;

#pragma mark Properties
@property (nonatomic, readonly) NSDate *timestamp;

@end
