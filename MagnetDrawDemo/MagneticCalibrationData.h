//
//  MagneticCalibrationData.h
//  MagnetDrawDemo
//
//  Created by Z on 11/12/15.
//  Copyright © 2015 dereknetto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagnetVector.h"

@interface MagneticCalibrationData : NSObject

@property (nonatomic) MagnetVector *left;
@property (nonatomic) MagnetVector *middle;
@property (nonatomic) MagnetVector *right;
@property (nonatomic) MagnetVector *bottom;

@end
