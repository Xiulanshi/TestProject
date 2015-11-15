//
//  MagneticCalibrationData.m
//  MagnetDrawDemo
//
//  Created by Z on 11/12/15.
//  Copyright © 2015 dereknetto. All rights reserved.
//

#import "MagneticCalibrationData.h"

@implementation MagneticCalibrationData

-(id)initWithLeft:(MagnetVector *)left Middle:(MagnetVector *)middle Right:(MagnetVector *)right AndBottom:(MagnetVector *)bottom{
    
    self = [super init];
    
    self.left = left;
    self.middle = middle;
    self.right = right;
    self.bottom = bottom;
    
    return self;
}

@end
