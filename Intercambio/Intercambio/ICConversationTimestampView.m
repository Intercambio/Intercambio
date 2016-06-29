//
//  ICConversationTimestampView.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 07.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICConversationTimestampView.h"
#import "ICConversationLayoutAttributes.h"

@interface ICConversationTimestampView () {
    UILabel *_timestampLabel;
}

@end

@implementation ICConversationTimestampView

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = kCFDateFormatterShortStyle;
        dateFormatter.timeStyle = kCFDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    });
    return dateFormatter;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _timestampLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _timestampLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _timestampLabel.textAlignment = NSTextAlignmentCenter;
        _timestampLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        [self addSubview:_timestampLabel];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if ([layoutAttributes isKindOfClass:[ICConversationLayoutTimestampAttributes class]]) {
        ICConversationLayoutTimestampAttributes *attributes = (ICConversationLayoutTimestampAttributes *)layoutAttributes;
        _timestampLabel.text = attributes.timestamp ? [[[self class] dateFormatter] stringFromDate:attributes.timestamp] : nil;
    }
    [super applyLayoutAttributes:layoutAttributes];
}

@end
