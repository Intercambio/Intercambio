//
//  ICUserInterface.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICAppWireframe;

@protocol ICUserInterface <NSObject>

@property (nonatomic, weak) ICAppWireframe *appWireframe;

@end
