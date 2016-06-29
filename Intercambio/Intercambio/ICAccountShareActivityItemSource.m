//
//  ICAccountShareActivityItemSource.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <CoreXMPP/CoreXMPP.h>

#import "ICAccountShareActivityItemSource.h"

@implementation ICAccountShareActivityItemSource

#pragma mark Life-cycle

- (instancetype)initWithURI:(NSURL *)URI
{
    self = [super init];
    if (self) {
        _URI = URI;
    }
    return self;
}

#pragma mark UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You can reach me on Jabber via %@", nil), [self.URI absoluteString]];
    return message;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You can reach me on Jabber via %@", nil), [self.URI absoluteString]];
    return message;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(nullable NSString *)activityType
{
    return NSLocalizedString(@"Write me via Jabber", nil);
}

@end
