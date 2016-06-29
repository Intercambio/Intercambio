//
//  ICAccountOptionsViewController.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 22.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountOptionsViewController.h"

@interface ICAccountOptionsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *websocketURLField;
@end

@implementation ICAccountOptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.websocketURLField.text = [self.account.options[@"XMPPWebsocketStreamURLKey"] absoluteString];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(save:)];
}

#pragma mark Actions

- (void)save:(id)sender
{
    NSDictionary *newOptions = [self options];

    if (![self.account.options isEqual:newOptions]) {
        [self.account updateWithOptions:newOptions];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (NSDictionary *)options
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];

    NSURL *websocketURL = nil;
    if (self.websocketURLField.text) {
        websocketURL = [NSURL URLWithString:self.websocketURLField.text];
    }
    if (websocketURL) {
        options[@"XMPPWebsocketStreamURLKey"] = websocketURL;
    }

    return options;
}

@end
