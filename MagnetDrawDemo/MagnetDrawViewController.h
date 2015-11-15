//
//  MagnetDrawViewController.h
//  MagnetDrawDemo
//
//  Created by Z on 11/10/15.
//  Copyright © 2015 dereknetto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MagnetDrawViewController : UIViewController <CLLocationManagerDelegate>
{
    CGPoint lastPoint;
    CGPoint moveBackTo;
    CGPoint currentPoint;
    CGPoint location;
    NSDate *lastClick;
   // BOOL mouseSwiped;
    UIImageView *drawImage;
    UIImageView *frontImage;
}

@end
