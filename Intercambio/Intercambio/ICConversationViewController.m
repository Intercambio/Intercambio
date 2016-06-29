//
//  ICNewConversationViewController.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.04.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationViewController.h"
#import "CLTokenInputView.h"
#import "ICAccountPickerViewController.h"
#import "ICAppWireframe.h"
#import "ICAvatarCell.h"
#import "ICConversationLayout.h"
#import "ICConversationLayoutItem_Message.h"
#import "ICErrorCell.h"
#import "ICMessageCell.h"
#import "ICMessageComposeCell.h"
#import <CoreXMPP/CoreXMPP.h>
#import <IntercambioCore/IntercambioCore.h>

@interface UICollectionView_ICNewConversationViewController : UICollectionView
@end

@implementation UICollectionView_ICNewConversationViewController

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [super scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
}

@end

@interface ICConversationViewController () <UITextViewDelegate, CLTokenInputViewDelegate> {
    FTCollectionViewAdapter *_collectionViewAdapter;
    id<FTDataSource, FTReverseDataSource, FTMutableDataSource, FTReverseMutableDataSource> _dataSource;
    NSMapTable *_composeCellsByTextView;
    BOOL _endpointSearchBarHidden;
    BOOL _shouldScrollToBottom;
    UITextView *_dummyTextView;
    UIBarButtonItem *_sendButton;
    CLTokenInputView *_endpointSearchBar;
    id<ICAccountViewModel> _selectedAccount;
}

@property (nonatomic, strong) id<ICConversationViewModel> conversation;

@end

@implementation ICConversationViewController

@synthesize appWireframe = _appWireframe;

#pragma mark Life-cycle

- (instancetype)init
{
    ICConversationLayout *layout = [[ICConversationLayout alloc] init];
    layout.itemLayoutMargins = UIEdgeInsetsMake(8, 8, 8, 8);
    layout.interitemSpacing = 4;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _endpointSearchBarHidden = YES;
        _composeCellsByTextView = [NSMapTable weakToStrongObjectsMapTable];
        self.hidesBottomBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return self;
}

- (void)dealloc
{
    _collectionViewAdapter.delegate = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;

    self.collectionView = [[UICollectionView_ICNewConversationViewController alloc] initWithFrame:self.view.bounds
                                                                             collectionViewLayout:self.collectionView.collectionViewLayout];

    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollsToTop = YES;
    self.collectionView.alwaysBounceVertical = YES;

    self.collectionView.allowsSelection = NO;
    self.collectionView.allowsMultipleSelection = NO;

    _collectionViewAdapter = [[FTCollectionViewAdapter alloc] initWithCollectionView:self.collectionView];
    _collectionViewAdapter.delegate = self;
    _collectionViewAdapter.reloadMovedItems = YES;
    _collectionViewAdapter.editing = YES;
    _collectionViewAdapter.dataSource = _dataSource;

    [self.collectionView registerClass:[ICMessageCell class] forCellWithReuseIdentifier:@"ICMessageCell"];
    [self.collectionView registerClass:[ICMessageComposeCell class] forCellWithReuseIdentifier:@"ICMessageComposeCell"];
    [self.collectionView registerClass:[ICErrorCell class] forCellWithReuseIdentifier:@"ICErrorCell"];
    [self.collectionView registerClass:[ICAvatarCell class] forSupplementaryViewOfKind:ICConversationLayoutElementKindAvatar withReuseIdentifier:@"ICAvatarCell"];

    [_collectionViewAdapter forItemsMatchingPredicate:[NSPredicate predicateWithFormat:@"type == \"error\""]
                           useCellWithReuseIdentifier:@"ICErrorCell"
                                         prepareBlock:^(ICErrorCell *cell,
                                                        id<ICMessageViewModel> cellModel,
                                                        NSIndexPath *indexPath,
                                                        id<FTDataSource> dataSource) {
                                             cell.cellModel = cellModel;
                                         }];

    [_collectionViewAdapter forItemsMatchingPredicate:[NSPredicate predicateWithFormat:@"editable == YES"]
                           useCellWithReuseIdentifier:@"ICMessageComposeCell"
                                         prepareBlock:^(ICMessageComposeCell *cell,
                                                        id<ICMessageViewModel> cellModel,
                                                        NSIndexPath *indexPath,
                                                        id<FTDataSource> dataSource) {
                                             cell.cellModel = cellModel;
                                             cell.placeholderText = NSLocalizedString(@"Say something …", nil);
                                         }];

    [_collectionViewAdapter forItemsMatchingPredicate:nil
                           useCellWithReuseIdentifier:@"ICMessageCell"
                                         prepareBlock:^(ICMessageCell *cell,
                                                        id<ICMessageViewModel> cellModel,
                                                        NSIndexPath *indexPath,
                                                        id<FTDataSource> dataSource) {
                                             cell.cellModel = cellModel;
                                         }];

    [_collectionViewAdapter forSupplementaryViewsOfKind:ICConversationLayoutElementKindAvatar
                                      matchingPredicate:nil
                             useViewWithReuseIdentifier:@"ICAvatarCell"
                                           prepareBlock:^(ICAvatarCell *cell,
                                                          id<ICMessageViewModel> cellModel,
                                                          NSIndexPath *indexPath,
                                                          id<FTDataSource> dataSource) {
                                               cell.cellModel = cellModel;
                                           }];

    _dummyTextView = [[UITextView alloc] init];
    _dummyTextView.scrollsToTop = NO;
    [self.view insertSubview:_dummyTextView belowSubview:self.collectionView];

    _sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(send:)];

    _shouldScrollToBottom = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.conversationURI == nil) {
        self.endpointSearchBarHidden = NO;
    }
}

- (void)viewDidLayoutSubviews
{
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    if (_endpointSearchBar == nil) {
        contentInset.top = self.topLayoutGuide.length;
    } else {
        contentInset.top = CGRectGetMaxY(_endpointSearchBar.frame);
    }

    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, contentInset)) {
        self.collectionView.contentInset = contentInset;
        self.collectionView.scrollIndicatorInsets = contentInset;
    }

    if (_shouldScrollToBottom) {
        [self scrollToBottom:nil animated:NO];
        _shouldScrollToBottom = NO;
    }
}

#pragma mark Conversation

- (void)setConversationURI:(NSURL *)conversationURI
{
    if (![[self.conversation conversationURI] isEqual:conversationURI]) {
        if (conversationURI) {
            self.conversation = [self.conversationProvider conversationWithURI:conversationURI];
        } else {
            self.conversation = nil;
        }
    }
}

- (NSURL *)conversationURI
{
    return [self.conversation conversationURI];
}

- (void)setConversation:(id<ICConversationViewModel>)conversation
{
    if (_conversation != conversation) {
        _conversation = conversation;

        if (conversation) {
            self.dataSource = [self.dataSourceProvider messageDataSourceWithConversationURI:[conversation conversationURI]];
            self.title = [conversation title];
            _shouldScrollToBottom = YES;
        } else {
            self.dataSource = nil;
            self.title = nil;
        }
    }
}

#pragma mark Data Source

- (void)setDataSource:(id<FTDataSource, FTReverseDataSource, FTMutableDataSource, FTReverseMutableDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        _collectionViewAdapter.dataSource = dataSource;
    }
}

- (void)setAccountDataSource:(id<FTDataSource, FTReverseDataSource>)accountDataSource
{
    if (_accountDataSource != accountDataSource) {
        _accountDataSource = accountDataSource;

        if (_selectedAccount != nil) {
            BOOL hasAccount = [accountDataSource indexPathsOfItem:_selectedAccount] > 0;
            if (!hasAccount) {
                _selectedAccount = nil;
            }
        }

        if (_selectedAccount == nil && [accountDataSource numberOfSections] > 0 && [accountDataSource numberOfItemsInSection:0] > 0) {
            _selectedAccount = [accountDataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }
}

#pragma mark Actions

- (IBAction)send:(id)sender
{
    self.endpointSearchBarHidden = YES;

    for (ICMessageComposeCell *cell in [_composeCellsByTextView objectEnumerator]) {

        if ([cell.messageTextView isFirstResponder]) {

            id<ICMessageViewModel> cellModel = cell.cellModel;

            NSString *text = [[cellModel.textStorage string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            BOOL hasContent = [text length] > 0;

            if (hasContent) {
                [_dummyTextView becomeFirstResponder];

                [_dataSource insertItemWithProperties:@{}
                                          basedOnType:cellModel
                                          atIndexPath:nil];

                if ([_dataSource numberOfFutureItemTypesInSection:0] > 0) {
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:[_dataSource numberOfItemsInSection:0]
                                                                    inSection:0];
                    ICMessageComposeCell *cell = (ICMessageComposeCell *)[self.collectionView cellForItemAtIndexPath:newIndexPath];
                    [cell.messageTextView becomeFirstResponder];
                }
            }

            return;
        }
    }
}

- (IBAction)scrollToBottom:(id)sender
{
    [self scrollToBottom:sender animated:YES];
}

- (IBAction)scrollToBottom:(id)sender animated:(BOOL)animated
{
    CGPoint contentOffset = CGPointMake(0, 0);
    if (self.collectionView.contentSize.height > CGRectGetHeight(UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset))) {
        contentOffset.y = self.collectionView.contentSize.height - (CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.bottom);
    } else {
        contentOffset.y = -1 * self.collectionView.contentInset.top;
    }
    [self.collectionView setContentOffset:contentOffset animated:animated];
}

- (IBAction)showAccountPicker:(id)sender
{
    ICAccountPickerViewController *accountPicker = [[ICAccountPickerViewController alloc] init];
    accountPicker.dataSource = self.accountDataSource;
    accountPicker.selectedAccount = _selectedAccount;
    accountPicker.delegate = self;

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:accountPicker];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:nc
                       animated:YES
                     completion:^{

                     }];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ICMessageComposeCell class]]) {
        ICMessageComposeCell *composeCell = (ICMessageComposeCell *)cell;
        [_composeCellsByTextView setObject:cell forKey:composeCell.messageTextView];
        composeCell.messageTextView.delegate = self;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
    didEndDisplayingCell:(UICollectionViewCell *)cell
      forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ICMessageComposeCell class]]) {
        ICMessageComposeCell *composeCell = (ICMessageComposeCell *)cell;
        [_composeCellsByTextView removeObjectForKey:composeCell.messageTextView];
        if ([composeCell.messageTextView isFirstResponder]) {
            [composeCell.messageTextView resignFirstResponder];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(delete:)) {
        if ([_dataSource conformsToProtocol:@protocol(FTMutableDataSource)]) {
            id<FTMutableDataSource> mutableDataSource = (id<FTMutableDataSource>)_dataSource;
            if ([mutableDataSource canEditItemAtIndexPath:indexPath] &&
                [mutableDataSource canDeleteItemAtIndexPath:indexPath]) {
                return YES;
            }
        }
    }

    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if (action == @selector(delete:)) {
        if ([_dataSource conformsToProtocol:@protocol(FTMutableDataSource)]) {
            id<FTMutableDataSource> mutableDataSource = (id<FTMutableDataSource>)_dataSource;

            if ([mutableDataSource canEditItemAtIndexPath:indexPath] &&
                [mutableDataSource canDeleteItemAtIndexPath:indexPath]) {

                [_collectionViewAdapter performUserDrivenChange:^{
                    [mutableDataSource deleteItemAtIndexPath:indexPath];
                    [self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
                }];
            }
        }
    }
}

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (ICMessageComposeCell *cell in [[_composeCellsByTextView objectEnumerator] allObjects]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath == nil) {
            if ([cell.messageTextView isFirstResponder]) {
                [cell.messageTextView resignFirstResponder];
            }
        }
    }
}

#pragma mark Endpoint Search Field

- (void)setEndpointSearchBarHidden:(BOOL)endpointSearchBarHidden
{
    if (endpointSearchBarHidden != _endpointSearchBarHidden) {
        _endpointSearchBarHidden = endpointSearchBarHidden;
        if (endpointSearchBarHidden) {
            [_endpointSearchBar removeFromSuperview];
            _endpointSearchBar = nil;
        } else if (_endpointSearchBar == nil) {
            _endpointSearchBar = [[CLTokenInputView alloc] init];
            _endpointSearchBar.translatesAutoresizingMaskIntoConstraints = NO;
            _endpointSearchBar.delegate = self;
            _endpointSearchBar.placeholderText = NSLocalizedString(@"Enter Address", nil);
            _endpointSearchBar.backgroundColor = [UIColor whiteColor];
            _endpointSearchBar.drawBottomBorder = YES;

            UIButton *accountButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [accountButton setImage:[UIImage imageNamed:@"779-users"] forState:UIControlStateNormal];
            [accountButton sizeToFit];
            [accountButton addTarget:self action:@selector(showAccountPicker:) forControlEvents:UIControlEventTouchUpInside];
            _endpointSearchBar.accessoryView = accountButton;

            [self.view addSubview:_endpointSearchBar];

            id topGuide = self.topLayoutGuide;

            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_endpointSearchBar]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_endpointSearchBar)]];

            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide][_endpointSearchBar]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_endpointSearchBar, topGuide)]];
        }
    }
}

#pragma mark CLTokenInputViewDelegate

- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"xmpp";
    components.path = text;

    return [[CLToken alloc] initWithDisplayText:text context:[components URL]];
}

- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token
{
    [self updateConversation];
}

- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token
{
    [self updateConversation];
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.navigationItem setRightBarButtonItem:_sendButton animated:YES];

    NSString *text = [[textView.textContainer.layoutManager.textStorage string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL hasContent = [text length] > 0;

    _sendButton.enabled = hasContent;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = [[textView.textContainer.layoutManager.textStorage string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL hasContent = [text length] > 0;

    _sendButton.enabled = hasContent;

    UICollectionViewLayoutInvalidationContext *context = [[[[self.collectionView.collectionViewLayout class] invalidationContextClass] alloc] init];

    ICMessageComposeCell *cell = [_composeCellsByTextView objectForKey:textView];
    NSIndexPath *futureItemIndexPath = [[_dataSource indexPathsOfFutureItem:cell.cellModel] firstObject];
    if (futureItemIndexPath) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_dataSource numberOfItemsInSection:futureItemIndexPath.section] + futureItemIndexPath.item
                                                     inSection:futureItemIndexPath.section];

        [context invalidateItemsAtIndexPaths:@[ indexPath ]];

        ICConversationLayoutAttributes *attributes = (ICConversationLayoutAttributes *)[self.collectionView layoutAttributesForItemAtIndexPath:indexPath];

        CGSize currentSize = attributes.size;
        CGSize preferredSize = [self collectionView:self.collectionView
                                             layout:self.collectionView.collectionViewLayout
                             sizeForItemAtIndexPath:indexPath
                                           maxWidth:attributes.maxWidth
                                      layoutMargins:attributes.layoutMargins];

        CGFloat heightAdjustment = preferredSize.height - currentSize.height;

        if (heightAdjustment) {
            context.contentSizeAdjustment = CGSizeMake(0, heightAdjustment);
            context.contentOffsetAdjustment = CGPointMake(0, heightAdjustment);
        }

        [self.collectionViewLayout invalidateLayoutWithContext:context];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

#pragma mark UICollectionViewDelegateConversationLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
                  maxWidth:(CGFloat)maxWidth
             layoutMargins:(UIEdgeInsets)layoutMargins
{
    id<ICMessageViewModel> cellModel = [self cellModelAtIndexPath:indexPath];

    CGSize preferredSize;

    if ([[cellModel type] isEqualToString:@"error"]) {
        preferredSize = [ICErrorCell preferredSizeWithCellModel:cellModel
                                                          width:maxWidth
                                                  layoutMargins:layoutMargins];
    } else if (cellModel.editable) {
        preferredSize = [ICMessageComposeCell preferredSizeWithCellModel:cellModel
                                                                   width:maxWidth
                                                           layoutMargins:layoutMargins];
    } else {
        preferredSize = [ICMessageCell preferredSizeWithCellModel:cellModel
                                                            width:maxWidth
                                                    layoutMargins:layoutMargins];
    }

    // TODO: Cache preferred size for cellModel.textStorage with width, layoutmargins

    preferredSize.height = ceil(preferredSize.height);
    preferredSize.width = ceil(preferredSize.width);

    return preferredSize;
}

- (id<ICConversationLayoutItem>)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout layoutItemOfItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICMessageViewModel> cellModel = [self cellModelAtIndexPath:indexPath];
    return [[ICConversationLayoutItem_Message alloc] initWithMessageViewModel:cellModel];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout timestampOfItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICMessageViewModel> cellModel = [self cellModelAtIndexPath:indexPath];
    return [cellModel timestamp];
}

- (id<ICMessageViewModel>)cellModelAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICMessageViewModel> cellModel = nil;

    NSUInteger numberOfItemsInSection = [_dataSource numberOfItemsInSection:indexPath.section];
    if (indexPath.item < numberOfItemsInSection) {
        cellModel = [_dataSource itemAtIndexPath:indexPath];
    } else if (_collectionViewAdapter.editing && [_dataSource conformsToProtocol:@protocol(FTMutableDataSource)]) {
        id<FTMutableDataSource> mutableDataSource = (id<FTMutableDataSource>)_dataSource;
        NSIndexPath *futureItemIndexPath = [NSIndexPath indexPathForItem:indexPath.item - numberOfItemsInSection
                                                               inSection:indexPath.section];
        cellModel = [mutableDataSource futureItemTypeAtIndexPath:futureItemIndexPath];
    }

    return cellModel;
}

#pragma mark ICAccountPickerViewControllerDelegate

- (void)accountPicker:(ICAccountPickerViewController *)accountPicker didPickAccount:(id<ICAccountViewModel>)account;
{
    [accountPicker dismissViewControllerAnimated:YES
                                      completion:^{

                                      }];
    _selectedAccount = account;
    [self updateConversation];
}

- (void)accountPickerDidCancel:(ICAccountPickerViewController *)accountPicker
{
    [accountPicker dismissViewControllerAnimated:YES
                                      completion:^{

                                      }];
}

#pragma mark -

- (void)updateConversation
{
    NSArray *URIs = [_endpointSearchBar.allTokens valueForKey:@"context"];
    if (_selectedAccount && [URIs count] == 1) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:[_selectedAccount accountURI] resolvingAgainstBaseURL:NO];
        components.path = [NSString stringWithFormat:@"/%@", [[URIs firstObject] path]];
        self.conversationURI = [components URL];
    } else {
        self.conversationURI = nil;
    }
}

@end
