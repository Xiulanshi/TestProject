//
//  MagnetVector.h
//  MagnetDrawDemo
//
//  Created by Z on 11/12/15.
//  Copyright © 2015 dereknetto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MagnetVector : NSObject

@property (nonatomic) CGFloat magnitude;
@property (nonatomic) CGFloat direction;


-(id)initWithVector:(MagnetVector *)vector;
-(id)initWithMagnitude:(CGFloat)magnitude AndDirection:(CGFloat)direction;

-(CGPoint)XYpointFromMagnitudeAndDirectionInDegrees;



@end
