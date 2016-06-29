//
//  ICConversationLayoutItem_Message.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 06.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IntercambioCore/IntercambioCore.h>

#import "ICConversationLayout.h"

@interface ICConversationLayoutItem_Message : NSObject <ICConversationLayoutItem>

#pragma mark Life-cycle
- (instancetype)initWithMessageViewModel:(id<ICMessageViewModel>)messageViewModel;

#pragma mark Message View Model
@property (nonatomic, readonly) id<ICMessageViewModel> messageViewModel;

@end
