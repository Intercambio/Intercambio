//
//  ICMessageComposeCell.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 10.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICMessageComposeCell.h"
#import "ICConversationLayoutAttributes.h"
#import "ICMessageBackgroundView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface UIScrollView_ICMessageComposeCell : UIScrollView

@end

@interface ICMessageComposeCell () {
    UIScrollView *_containerScrollView;
    NSLayoutManager *_messageLayoutManager;
    NSTextContainer *_messageTextContainer;
    UILabel *_placeholderLabel;
    BOOL _first;
    BOOL _last;
}

@end

@implementation ICMessageComposeCell

#pragma mark Preferred Size

+ (CGSize)preferredSizeWithCellModel:(id<ICMessageViewModel>)cellModel
                               width:(CGFloat)width
                       layoutMargins:(UIEdgeInsets)layoutMargins
{
    NSString *text = [cellModel.textStorage string];
    BOOL hasContent = [text length] > 0;

    CGFloat lineHeight = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] lineHeight] + 1; // The UITextView needs one point more.
    CGSize defaultSize = CGSizeMake(width, layoutMargins.top + layoutMargins.bottom + lineHeight);

    if (hasContent) {
        CGFloat contentWith = width - (layoutMargins.left + layoutMargins.right);

        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.preferredMaxLayoutWidth = contentWith;
        label.attributedText = cellModel.textStorage;
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        CGSize preferredSize = [label sizeThatFits:CGSizeMake(contentWith, CGFLOAT_MAX)];

        if (CGSizeEqualToSize(preferredSize, CGSizeZero)) {
            return defaultSize;
        } else {
            preferredSize.width += layoutMargins.left + layoutMargins.right;
            preferredSize.height += layoutMargins.top + layoutMargins.bottom;
            preferredSize.width = width;
            preferredSize.height = fmax(defaultSize.height, preferredSize.height);
            return preferredSize;
        }
    } else {
        return defaultSize;
    }
}

#pragma mark Life-cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ICMessageBackgroundView *backgroundView = [[ICMessageBackgroundView alloc] initWithFrame:frame];
        backgroundView.cornerRadius = 8.0;
        backgroundView.roundedCorners = UIRectCornerAllCorners;
        self.backgroundView = backgroundView;

        self.contentView.backgroundColor = [UIColor clearColor];

        _containerScrollView = [[UIScrollView_ICMessageComposeCell alloc] init];
        _containerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _containerScrollView.scrollEnabled = NO;
        [self.contentView addSubview:_containerScrollView];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_containerScrollView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_containerScrollView)]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerScrollView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_containerScrollView)]];

        _messageLayoutManager = [[NSLayoutManager alloc] init];
        _messageTextContainer = [[NSTextContainer alloc] init];
        [_messageLayoutManager addTextContainer:_messageTextContainer];

        _messageTextView = [[UITextView alloc] initWithFrame:frame textContainer:_messageTextContainer];
        _messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _messageTextView.scrollEnabled = NO;
        _messageTextView.textContainer.lineFragmentPadding = 0;
        _messageTextView.textContainerInset = UIEdgeInsetsZero;
        _messageTextView.backgroundColor = [UIColor clearColor];
        _messageTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        [_containerScrollView addSubview:_messageTextView];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTopMargin
                                                                    multiplier:1
                                                                      constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeftMargin
                                                                    multiplier:1
                                                                      constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageTextView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeRightMargin
                                                                    multiplier:1
                                                                      constant:0]];

        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _placeholderLabel.numberOfLines = 1;
        _placeholderLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        [self.contentView insertSubview:_placeholderLabel belowSubview:_containerScrollView];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_placeholderLabel]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_placeholderLabel)]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_placeholderLabel]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_placeholderLabel)]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewTextDidChange:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:_messageTextView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _messageTextView.selectedRange = NSMakeRange(0, 0);
}

- (IBAction)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setValue:[_cellModel.textStorage string]
                             forPasteboardType:(NSString *)kUTTypeUTF8PlainText];
}

- (void)setCellModel:(id<ICMessageViewModel>)cellModel
{
    if (_cellModel != cellModel) {
        _cellModel = cellModel;
        NSTextStorage *textStorage = _cellModel.textStorage;
        if (_messageTextView.textStorage != textStorage) {
            if (_messageLayoutManager.textStorage) {
                [_messageLayoutManager.textStorage removeLayoutManager:_messageLayoutManager];
            }
            [textStorage addLayoutManager:_messageTextView.layoutManager];
        }

        ICMessageBackgroundView *backgroundView = (ICMessageBackgroundView *)self.backgroundView;

        backgroundView.borderStyle = _cellModel.temporary ? ICMessageBackgroundViewBorderStyleDashed : ICMessageBackgroundViewBorderStyleNone;

        switch (_cellModel.direction) {
        case ICMessageDirectionIn:
            backgroundView.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1];
            backgroundView.borderColor = [UIColor blackColor];
            _messageTextView.textColor = [UIColor blackColor];
            break;

        case ICMessageDirectionOut:
            backgroundView.backgroundColor = _cellModel.temporary ? [UIColor whiteColor] : self.tintColor;
            backgroundView.borderColor = self.tintColor;
            _messageTextView.textColor = _cellModel.temporary ? [UIColor blackColor] : [UIColor whiteColor];
            break;

        default:
            self.contentView.backgroundColor = [UIColor whiteColor];
            backgroundView.borderColor = self.tintColor;
            _messageTextView.textColor = [UIColor blackColor];
            break;
        }
    }

    [self updateBackgroundCorners];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderLabel.text = placeholderText;
}

- (NSString *)placeholderText
{
    return _placeholderLabel.text;
}

- (void)updateBackgroundCorners
{
    UIRectCorner corners;

    switch (_cellModel.direction) {
    case ICMessageDirectionIn:
        corners = UIRectCornerTopRight | UIRectCornerBottomRight;
        break;

    case ICMessageDirectionOut:
        corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;
        break;

    default:
        corners = UIRectCornerAllCorners;
        break;
    }

    if (_first) {
        corners = corners | UIRectCornerTopLeft | UIRectCornerTopRight;
    }

    if (_last) {
        corners = corners | UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }

    [(ICMessageBackgroundView *)self.backgroundView setRoundedCorners:corners];
    [(ICMessageBackgroundView *)self.selectedBackgroundView setRoundedCorners:corners];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    UICollectionViewLayoutAttributes *attributes = [layoutAttributes copy];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:attributes.size
                                  withHorizontalFittingPriority:UILayoutPriorityRequired
                                        verticalFittingPriority:UILayoutPriorityFittingSizeLevel];

    size.height = fmax(size.height, _messageTextView.font.lineHeight + self.layoutMargins.top + self.layoutMargins.bottom);

    attributes.size = size;
    return attributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    _containerScrollView.contentSize = layoutAttributes.size;

    if ([layoutAttributes isKindOfClass:[ICConversationLayoutAttributes class]]) {
        ICConversationLayoutAttributes *attributes = (ICConversationLayoutAttributes *)layoutAttributes;
        _first = attributes.first;
        _last = attributes.last;
        self.contentView.layoutMargins = attributes.layoutMargins;
    }
    [super applyLayoutAttributes:layoutAttributes];

    [self updateBackgroundCorners];
    [self.backgroundView setNeedsDisplay];
}

- (void)textViewTextDidChange:(NSNotification *)notification
{
    _placeholderLabel.hidden = [_cellModel.textStorage length] > 0;
}

@end

@implementation UIScrollView_ICMessageComposeCell

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
}

@end
