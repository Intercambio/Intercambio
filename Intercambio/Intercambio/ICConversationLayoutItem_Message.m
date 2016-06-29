//
//  ICConversationLayoutItem_Message.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationLayoutItem_Message.h"

@implementation ICConversationLayoutItem_Message

#pragma mark Life-cycle

- (instancetype)initWithMessageViewModel:(id<ICMessageViewModel>)messageViewModel
{
    self = [super init];
    if (self) {
        _messageViewModel = messageViewModel;
    }
    return self;
}

#pragma mark ICConversationLayoutItem

- (id<NSObject>)originIdentifier
{
    return [_messageViewModel originURI];
}

- (id<NSObject>)typeIdentifier
{
    return [_messageViewModel type];
}

- (ICConversationLayoutItemDirection)direction
{
    switch (_messageViewModel.direction) {
    case ICMessageDirectionIn:
        return ICConversationLayoutItemDirectionIn;
    case ICMessageDirectionOut:
        return ICConversationLayoutItemDirectionOut;
    default:
        return ICConversationLayoutItemDirectionUnknown;
    }
}

- (BOOL)isTemporary
{
    return [_messageViewModel temporary];
}

#pragma mark NSObject

- (NSUInteger)hash
{
    return [self.originIdentifier hash] + [self.typeIdentifier hash] + self.temporary;
}

- (BOOL)isEqual:(id<ICConversationLayoutItem>)object
{
    if (object == nil) {
        return NO;
    } else if ([object conformsToProtocol:@protocol(ICConversationLayoutItem)]) {

        if (![self.originIdentifier isEqual:object.originIdentifier]) {
            return NO;
        }

        if (![self.typeIdentifier isEqual:object.typeIdentifier]) {
            return NO;
        }

        if (self.direction != object.direction) {
            return NO;
        }

        if (self.temporary != object.temporary) {
            return NO;
        }

        return YES;
    } else {
        return NO;
    }
}

@end
