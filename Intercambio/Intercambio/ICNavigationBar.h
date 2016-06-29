//
//  ICNavigationBar.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@protocol ICNavigationBarDelegate <UINavigationBarDelegate>
@optional
- (void)navigationBar:(UINavigationBar *)navigationBar didTapAccount:(id<ICAccountViewModel>)account;
@end

@interface ICNavigationBar : UINavigationBar

@property (nonatomic, strong) NSArray<id<ICAccountViewModel>> *accounts;

@end
