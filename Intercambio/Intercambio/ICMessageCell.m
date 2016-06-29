//
//  ICMessageCell.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 08.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "UICollectionView+CellAction.h"

#import "ICConversationLayoutAttributes.h"
#import "ICMessageBackgroundView.h"

#import "ICMessageCell.h"

@interface ICMessageCell () {
    UILabel *_messageLabel;
    BOOL _first;
    BOOL _last;
}

@end

@implementation ICMessageCell

#pragma mark Preferred Size

+ (CGSize)preferredSizeWithCellModel:(id<ICMessageViewModel>)cellModel
                               width:(CGFloat)width
                       layoutMargins:(UIEdgeInsets)layoutMargins
{
    NSString *text = [[cellModel.textStorage string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL hasContent = [text length] > 0;

    if (hasContent) {
        CGFloat contentWith = width - (layoutMargins.left + layoutMargins.right);

        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.preferredMaxLayoutWidth = contentWith;
        label.attributedText = cellModel.textStorage;
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        CGSize preferredSize = [label sizeThatFits:CGSizeMake(contentWith, CGFLOAT_MAX)];

        if (CGSizeEqualToSize(preferredSize, CGSizeZero)) {
            return CGSizeZero;
        } else {
            preferredSize.width += layoutMargins.left + layoutMargins.right;
            preferredSize.height += layoutMargins.top + layoutMargins.bottom;
            return preferredSize;
        }
    } else {
        return CGSizeZero;
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

        ICMessageBackgroundView *selectedBackgroundView = [[ICMessageBackgroundView alloc] initWithFrame:frame];
        selectedBackgroundView.cornerRadius = 8.0;
        selectedBackgroundView.roundedCorners = UIRectCornerAllCorners;
        self.selectedBackgroundView = selectedBackgroundView;

        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.numberOfLines = 0;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        [self.contentView addSubview:_messageLabel];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_messageLabel]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_messageLabel)]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_messageLabel]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_messageLabel)]];
    }
    return self;
}

#pragma mark Actions

- (IBAction)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setValue:[_cellModel.textStorage string]
                             forPasteboardType:(NSString *)kUTTypeUTF8PlainText];
}

- (IBAction) delete:(id)sender
{
    id target = [self targetForAction:@selector(performAction:forCell:sender:) withSender:self];
    if (target) {
        [target performAction:@selector(delete:) forCell:self sender:sender];
    }
}

#pragma mark UICollectionViewCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateInterface];
}

#pragma mark Cell Model

- (void)setCellModel:(id<ICMessageViewModel>)cellModel
{
    if (_cellModel != cellModel) {
        _cellModel = cellModel;
        _messageLabel.attributedText = _cellModel.textStorage;
    }

    [self updateInterface];
}

- (void)updateInterface
{
    ICMessageBackgroundView *backgroundView = (ICMessageBackgroundView *)self.backgroundView;
    ICMessageBackgroundView *selectedBackgroundView = (ICMessageBackgroundView *)self.selectedBackgroundView;

    backgroundView.borderStyle = _cellModel.temporary ? ICMessageBackgroundViewBorderStyleDashed : ICMessageBackgroundViewBorderStyleNone;

    switch (_cellModel.direction) {
    case ICMessageDirectionIn:
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1];
        backgroundView.borderColor = [UIColor blackColor];
        _messageLabel.textColor = self.selected ? [UIColor whiteColor] : [UIColor blackColor];
        break;

    case ICMessageDirectionOut:
        backgroundView.backgroundColor = _cellModel.temporary ? [UIColor whiteColor] : self.tintColor;
        backgroundView.borderColor = self.tintColor;
        _messageLabel.textColor = _cellModel.temporary && self.selected == NO ? [UIColor blackColor] : [UIColor whiteColor];
        break;

    default:
        self.contentView.backgroundColor = [UIColor whiteColor];
        backgroundView.borderColor = self.tintColor;
        _messageLabel.textColor = self.selected ? [UIColor whiteColor] : [UIColor blackColor];
        break;
    }

    CGFloat backgroundColorComponents[4];

    [backgroundView.backgroundColor getHue:&backgroundColorComponents[0]
                                saturation:&backgroundColorComponents[1]
                                brightness:&backgroundColorComponents[2]
                                     alpha:&backgroundColorComponents[3]];

    selectedBackgroundView.backgroundColor = [UIColor colorWithHue:backgroundColorComponents[0]
                                                        saturation:backgroundColorComponents[1] * 0.9
                                                        brightness:backgroundColorComponents[2] * 0.7
                                                             alpha:backgroundColorComponents[3]];

    [self updateBackgroundCorners];
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
    CGFloat maxCellWidth = layoutAttributes.size.width;
    if ([layoutAttributes isKindOfClass:[ICConversationLayoutAttributes class]]) {
        maxCellWidth = [(ICConversationLayoutAttributes *)layoutAttributes maxWidth] ?: maxCellWidth;
    }

    _messageLabel.preferredMaxLayoutWidth = maxCellWidth - (self.layoutMargins.left + self.layoutMargins.right);
    return [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
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

@end
