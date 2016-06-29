//
//  ICMessageCell.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 08.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICMessageCell : UICollectionViewCell

#pragma mark Preferred Size
+ (CGSize)preferredSizeWithCellModel:(id<ICMessageViewModel>)cellModel
                               width:(CGFloat)width
                       layoutMargins:(UIEdgeInsets)layoutMargins;

#pragma mark Cell Model
@property (nonatomic, strong) id<ICMessageViewModel> cellModel;

@end
