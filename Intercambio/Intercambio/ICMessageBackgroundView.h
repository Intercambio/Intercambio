//
//  ICMessageBackgroundView.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 15.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ICMessageBackgroundViewBorderStyle) {
    ICMessageBackgroundViewBorderStyleNone,
    ICMessageBackgroundViewBorderStyleSolid,
    ICMessageBackgroundViewBorderStyleDashed
};

@interface ICMessageBackgroundView : UIView

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIRectCorner roundedCorners;

@property (nonatomic, readwrite) UIColor *borderColor;
@property (nonatomic, assign) ICMessageBackgroundViewBorderStyle borderStyle;

@end
