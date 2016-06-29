//
//  ICConnectionStateView.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@class ICConnectionStateView;

@protocol ICConnectionStateViewDelegate <NSObject>
@optional
- (void)connectionStateView:(ICConnectionStateView *)connectionStateView didTapAccount:(id<ICAccountViewModel>)account;
@end

@interface ICConnectionStateView : UIView

#pragma mark Delegate
@property (nonatomic, weak) id<ICConnectionStateViewDelegate> delegate;
#pragma mark Account
@property (nonatomic, strong) id<ICAccountViewModel> account;

@end
