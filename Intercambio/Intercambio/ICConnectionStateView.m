//
//  ICConnectionStateView.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConnectionStateView.h"

@interface ICConnectionStateView () {
    UILabel *_errorLabel;
    UILabel *_nameLabel;
    UILabel *_stateLabel;
    UILabel *_reconnectLabel;

    UIStackView *_containerStackView;

    CADisplayLink *_displayLink;

    UITapGestureRecognizer *_tapGestureRecognizer;
}

@end

@implementation ICConnectionStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _errorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _errorLabel.textAlignment = NSTextAlignmentRight;
        _errorLabel.text = @"⚡️";

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _nameLabel.textAlignment = NSTextAlignmentCenter;

        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _stateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _stateLabel.textAlignment = NSTextAlignmentLeft;

        _reconnectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reconnectLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _reconnectLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _reconnectLabel.textAlignment = NSTextAlignmentLeft;

        _containerStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
        _containerStackView.translatesAutoresizingMaskIntoConstraints = NO;
        _containerStackView.axis = UILayoutConstraintAxisHorizontal;
        _containerStackView.distribution = UIStackViewDistributionFill;
        _containerStackView.alignment = UIStackViewAlignmentFirstBaseline;
        _containerStackView.spacing = 6.0;

        [_containerStackView addArrangedSubview:_errorLabel];
        [_containerStackView addArrangedSubview:_nameLabel];
        [_containerStackView addArrangedSubview:_stateLabel];
        [_containerStackView addArrangedSubview:_reconnectLabel];

        [self addSubview:_containerStackView];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerStackView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_containerStackView)]];

        [self addConstraint:({
                  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_nameLabel
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1
                                                                                 constant:0];
                  constraint;
              })];

        [self addConstraint:({
                  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_nameLabel
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1
                                                                                 constant:0];
                  constraint;
              })];

        [self addConstraint:({
                  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:20];
                  constraint.priority = UILayoutPriorityDefaultHigh;
                  constraint;
              })];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(tap:)];

        [self addGestureRecognizer:_tapGestureRecognizer];

        [self updateUserInterface];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Actions

- (void)tap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(connectionStateView:didTapAccount:)]) {
            [self.delegate connectionStateView:self didTapAccount:self.account];
        }
    }
}

#pragma mark Account

- (void)setAccount:(id<ICAccountViewModel>)account
{
    if (_account != account) {
        _account = account;
        [self updateUserInterface];
    }
}

#pragma mark -

- (void)updateUserInterface
{
    _errorLabel.hidden = self.account.recentError == nil;
    _nameLabel.text = self.account.identifier;
    _stateLabel.text = [self textForClientState:self.account.connectionState];
    _stateLabel.hidden = self.account.enabled == NO || self.account.connectionState == ICAccountConnectionStateConnected;
    if (self.account.nextConnectionAttempt) {
        [self startReconnectTimer];
        [self updateReconnectTimer:nil];
    } else {
        [self stopReconnectTimer];
        [self updateReconnectTimer:nil];
    }
}

- (void)updateReconnectTimer:(CADisplayLink *)link
{
    if (self.account.nextConnectionAttempt) {
        NSTimeInterval nextConnection = [self.account.nextConnectionAttempt timeIntervalSinceNow];
        if (nextConnection > 0) {
            _reconnectLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.0f sec.", nil), nextConnection];
        } else {
            _reconnectLabel.text = nil;
        }
    } else {
        _reconnectLabel.text = nil;
    }
}

- (NSString *)textForClientState:(ICAccountConnectionState)state
{
    switch (state) {
    case ICAccountConnectionStateDisconnected:
        return @"☁️";
    case ICAccountConnectionStateConnecting:
        return @"🌤";
    case ICAccountConnectionStateConnected:
        return @"☀️";
    case ICAccountConnectionStateDisconnecting:
        return @"🌧";
    }
}

- (void)startReconnectTimer
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateReconnectTimer:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.frameInterval = 5;
    }
}

- (void)stopReconnectTimer
{
    [_displayLink invalidate];
    _displayLink = nil;
}

@end
