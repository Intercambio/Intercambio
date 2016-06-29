//
//  ICMessageComposeCell.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 10.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICMessageComposeCell : UICollectionViewCell

#pragma mark Preferred Size
+ (CGSize)preferredSizeWithCellModel:(id<ICMessageViewModel>)cellModel
                               width:(CGFloat)width
                       layoutMargins:(UIEdgeInsets)layoutMargins;

@property (nonatomic, readonly) UITextView *messageTextView;
@property (nonatomic, strong) id<ICMessageViewModel> cellModel;
@property (nonatomic, strong) NSString *placeholderText;

@end
