//
//  ICConversationUserInterface.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICUserInterface.h"

@protocol ICConversationUserInterface <ICUserInterface>

@property (nonatomic, strong) NSURL *conversationURI;

@end
