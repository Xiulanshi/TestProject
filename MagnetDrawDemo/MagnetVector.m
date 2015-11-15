//
//  MagnetVector.m
//  MagnetDrawDemo
//
//  Created by Z on 11/12/15.
//  Copyright © 2015 dereknetto. All rights reserved.
//

#import "MagnetVector.h"

@implementation MagnetVector


-(id)initWithVector:(MagnetVector *)vector{
    
    self = [super init];
    
    self.magnitude = vector.magnitude;
    self.direction = vector.direction;
    
    return self;
}


-(id)initWithMagnitude:(CGFloat)magnitude AndDirection:(CGFloat)direction{
    
    self = [super init];
    
    self.magnitude = magnitude;
    self.direction = direction;
    
    return self;
}

-(CGPoint)XYpointFromMagnitudeAndDirectionInDegrees{
    
    CGFloat x = self.magnitude * cos([self degreesToRadians:self.direction]);
    CGFloat y = self.magnitude * sin([self degreesToRadians:self.direction]);
    
    return CGPointMake(x, y);
}


#pragma mark - angle conversions
- (CGFloat) degreesToRadians:(CGFloat) degrees {return degrees * M_PI / 180;};
- (CGFloat) radiansToDegrees:(CGFloat) radians {return radians * 180/M_PI;};

@end