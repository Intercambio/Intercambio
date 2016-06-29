//
//  ICConversationLayoutAttributes.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 09.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationLayoutAttributes.h"

@implementation ICConversationLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    ICConversationLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.alignment = self.alignment;
    attributes.first = self.first;
    attributes.last = self.last;
    attributes.maxWidth = self.maxWidth;
    attributes.layoutMargins = self.layoutMargins;
    return attributes;
}

@end

@implementation ICConversationLayoutTimestampAttributes

@end
