//
//  ICErrorCell.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 09.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationLayoutAttributes.h"
#import "UICollectionView+CellAction.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "ICErrorCell.h"

@interface ICErrorCell () {
    UILabel *_messageLabel;
}

@end

@implementation ICErrorCell

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
        label.text = [cellModel.textStorage string];
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

#pragma mark Cell Model

- (void)setCellModel:(id<ICMessageViewModel>)cellModel
{
    if (_cellModel != cellModel) {
        _cellModel = cellModel;
        _messageLabel.text = [_cellModel.textStorage string];
    }

    [self updateInterface];
}

- (void)updateInterface
{
    _messageLabel.textColor = [UIColor redColor];
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
        self.contentView.layoutMargins = attributes.layoutMargins;
    }
    [super applyLayoutAttributes:layoutAttributes];
}

@end
