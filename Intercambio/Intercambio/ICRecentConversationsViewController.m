//
//  ICRecentConversationsViewController.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICRecentConversationsViewController.h"
#import "ICAppWireframe.h"
#import "ICConversationCell.h"
#import <IntercambioCore/IntercambioCore.h>

@interface ICRecentConversationsViewController () {
    FTTableViewAdapter *_tableViewAdapter;
}

@end

@implementation ICRecentConversationsViewController

@synthesize appWireframe = _appWireframe;

#pragma mark Life-cycle

- (instancetype)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Conversations", nil);
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Conversations", nil)
                                                        image:[UIImage imageNamed:@"906-chat-3"]
                                                selectedImage:[UIImage imageNamed:@"906-chat-3-selected"]];
    }
    return self;
}

- (void)dealloc
{
    _tableViewAdapter.delegate = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"ICConversationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ICConversationCell"];
    self.tableView.rowHeight = UITableViewRowAnimationAutomatic;

    _tableViewAdapter = [[FTTableViewAdapter alloc] initWithTableView:self.tableView];
    _tableViewAdapter.delegate = self;
    _tableViewAdapter.reloadMovedItems = YES;
    _tableViewAdapter.dataSource = self.dataSource;

    [_tableViewAdapter forRowsMatchingPredicate:[NSPredicate predicateWithValue:YES]
                     useCellWithReuseIdentifier:@"ICConversationCell"
                                   prepareBlock:^(ICConversationCell *cell,
                                                  id<ICConversationViewModel> conversation,
                                                  NSIndexPath *indexPath,
                                                  id<FTDataSource> dataSource) {
                                       cell.cellModel = conversation;
                                   }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(addConversation:)];
}

#pragma mark Data Source

- (void)setDataSource:(id<FTDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        _tableViewAdapter.dataSource = dataSource;
    }
}

#pragma mark Actions

- (IBAction)addConversation:(id)sender
{
    [self.appWireframe presentUserInterfaceForNewConversationFromViewController:self];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICConversationViewModel> conversation = [self.dataSource itemAtIndexPath:indexPath];
    if (conversation) {
        [self.appWireframe presentUserInterfaceForConversationWithURI:[conversation conversationURI]
                                                   fromViewController:self];
    }
}

@end
