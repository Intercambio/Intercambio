//
//  ICAvatarCell.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 09.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICAvatarCell : UICollectionViewCell

#pragma mark Cell Model
@property (nonatomic, strong) id<ICMessageViewModel> cellModel;

@end
