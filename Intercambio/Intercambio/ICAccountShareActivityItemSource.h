//
//  ICAccountShareActivityItemSource.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICAccountShareActivityItemSource : NSObject <UIActivityItemSource>

#pragma mark Life-cycle
- (instancetype)initWithURI:(NSURL *)URI;

#pragma mark Account
@property (nonatomic, readonly) NSURL *URI;

@end
