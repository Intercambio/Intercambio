//
//  ICNavigationBar.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICNavigationBar.h"
#import "ICConnectionStateView.h"

@interface ICNavigationBar () <ICConnectionStateViewDelegate> {
    UIStackView *_stackView;
}

@end

@implementation ICNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
        _stackView.translatesAutoresizingMaskIntoConstraints = NO;
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.distribution = UIStackViewDistributionFill;
        _stackView.alignment = UIStackViewAlignmentFill;
        [self addSubview:_stackView];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stackView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_stackView)]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stackView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_stackView)]];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize navigationBarSize = [super sizeThatFits:size];
    CGSize stackViewSize = [_stackView sizeThatFits:CGSizeMake(size.width, 0)];
    navigationBarSize.height += stackViewSize.height;
    return navigationBarSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize stackViewSize = [_stackView sizeThatFits:CGSizeMake(self.bounds.size.width, 0)];
    _stackView.frame = CGRectMake(0, 0, self.bounds.size.width, stackViewSize.height);
}

- (void)setAccounts:(NSArray<id<ICAccountViewModel>> *)accounts
{
    if (_accounts != accounts) {
        _accounts = accounts;

        for (UIView *view in _stackView.arrangedSubviews) {
            [view removeFromSuperview];
        }

        for (id<ICAccountViewModel> account in accounts) {
            ICConnectionStateView *view = [[ICConnectionStateView alloc] init];
            view.delegate = self;
            view.account = account;
            [_stackView addArrangedSubview:view];
        }

        if ([self.delegate isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)self.delegate;
            if (navigationController.navigationBarHidden == NO) {
                navigationController.navigationBarHidden = YES;
                navigationController.navigationBarHidden = NO;
            }
        }
    }
}

#pragma mark ICConnectionStateViewDelegate

- (void)connectionStateView:(ICConnectionStateView *)connectionStateView didTapAccount:(id<ICAccountViewModel>)account
{
    if ([self.delegate respondsToSelector:@selector(navigationBar:didTapAccount:)]) {
        id<ICNavigationBarDelegate> delegate = (id<ICNavigationBarDelegate>)self.delegate;
        [delegate navigationBar:self didTapAccount:account];
    }
}

@end
