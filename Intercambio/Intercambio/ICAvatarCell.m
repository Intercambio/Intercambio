//
//  ICAvatarCell.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 09.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAvatarCell.h"

@interface ICAvatarCell () {
    UIImageView *_imageView;
}

@end

@implementation ICAvatarCell

#pragma mark Life-cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = CGRectGetWidth(_imageView.frame) / 2.0;
        _imageView.tintColor = [UIColor colorWithWhite:0.95 alpha:1];
        _imageView.backgroundColor = [UIColor colorWithWhite:0.76 alpha:1];
        [self.contentView addSubview:_imageView];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_imageView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_imageView)]];
    }
    return self;
}

#pragma mark UIView

- (void)layoutSubviews
{
    CGSize currentImageSize = _imageView.frame.size;
    [super layoutSubviews];
    CGSize newImageSize = _imageView.frame.size;

    if (!CGSizeEqualToSize(currentImageSize, newImageSize)) {
        [self updateImageWithPreferredSize:newImageSize];
        _imageView.layer.cornerRadius = CGRectGetWidth(_imageView.frame) / 2.0;
    }
}

#pragma mark Cell Model

- (void)setCellModel:(id<ICMessageViewModel>)cellModel
{
    if (_cellModel != cellModel) {
        _cellModel = cellModel;
        CGSize preferredSize = _imageView.frame.size;
        [self updateImageWithPreferredSize:preferredSize];
    }
}

#pragma mark -

- (void)updateImageWithPreferredSize:(CGSize)preferredSize
{
    _imageView.image = [UIImage imageNamed:@"avatar-small"];
}

@end
