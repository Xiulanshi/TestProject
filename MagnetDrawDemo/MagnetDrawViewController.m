//
//  MagnetDrawViewController.m
//  MagnetDrawDemo
//
//  Created by Z on 11/10/15.
//  Copyright © 2015 dereknetto. All rights reserved.
//

/* TO DO
 1)
 map "paperXY" coordinates to screen
 
 2) implement a displacement vector?
 */

#import "MagnetDrawViewController.h"
#import "MagneticCalibrationData.h"
#import "MagnetVector.h"

@interface MagnetDrawViewController ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLHeading *heading;

@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;

@property (nonatomic) MagnetVector *vector;
@property (nonatomic) MagneticCalibrationData *calibrationData;

@property (nonatomic) UIView *myView;

@end

@implementation MagnetDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkLocationServicesAuthorization];
    
    // setup the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    // setup delegate callbacks
    self.locationManager.delegate = self;
    
    //request permission for the app to use location services
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // heading service configuration
    self.locationManager.headingFilter = kCLHeadingFilterNone;
    
    // start the compass
    [self.locationManager startUpdatingHeading];
    
    //initialize vector
    self.vector = [[MagnetVector alloc] init];
    
    //initialize calibration vector
    self.calibrationData = [[MagneticCalibrationData alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    drawImage.image = [defaults objectForKey:@"drawImageKey"];
    drawImage = [[UIImageView alloc] initWithImage:nil];
    drawImage.frame = self.view.frame;
    [self.view addSubview:drawImage];

    
  //  [self moveBox:CGPointMake(0, 0)];
   // [self moveBox:CGPointMake(568, 320)];
    
}

-(void)checkLocationServicesAuthorization{
    // check if the hardware has a compass
    if ([CLLocationManager headingAvailable] == NO) {
        
        //alert user that there is no compass
        UIAlertController *noCompassAlert = [UIAlertController alertControllerWithTitle:@"No Compass" message:@"This device is not able to detect magnetic fields" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:noCompassAlert animated:YES completion:^{}];
        
    } else {
        //check if location services are authorized
        //alert user that location services are disabled
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) ||
            ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)){
            UIAlertController *noLocationServicesAlert = [UIAlertController alertControllerWithTitle:@"Location Services Disabled" message:@"Enable location services to detect magnetic fields" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:noLocationServicesAlert animated:YES completion:^{}];
        }
    }
}

// This delegate method is invoked when the location manager has heading data.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    
    self.heading = heading;
    self.vector.magnitude = sqrt(heading.x*heading.x + heading.y*heading.y + heading.z*heading.z);
    self.vector.direction = [self rawHeadingAngleInDeg];
    
    [self logDebugData];
    
 //   if ([self isCalibrated]) {
        
        if (self.myView == nil) { //only called once
            [self addTestView];
            [self logCalibrationData];
        }
    //insert code to move view
        
        CGPoint paperXY = [self.vector XYpointFromMagnitudeAndDirectionInDegrees];
        //paperXY.y = paperXY.y * -1;
        //CGPoint newPoint = CGPointMake(self.myView.layer.position.x, paperXY.y);
        //[self moveBox:newPoint];
        [self moveBox:paperXY];
    }
//}

-(void)moveBox:(CGPoint)point{
   // self.myView.layer.position = point;
    
    UIGraphicsBeginImageContext(CGSizeMake(568, 320));
    [drawImage.image drawInRect:CGRectMake(0, 0, 568, 320)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 1, 0, 1);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    [drawImage setFrame:CGRectMake(0, 0, 568, 320)];
    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    lastPoint = point;
    
    [self.view addSubview:drawImage];
    
}


// This delegate method is invoked when the location managed encounters an error condition.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        // This error indicates that the user has denied the application's request to use location services.
        [manager stopUpdatingHeading];
    } else if ([error code] == kCLErrorHeadingFailure) {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}

-(void)addTestView{
    self.myView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2, 50, 50)];
    
    self.myView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.myView];
}

-(CGFloat)rawHeadingAngleInDeg{
    CGFloat xVec = [[self class] degreesToRadians:self.heading.x];
    CGFloat yVec = [[self class] degreesToRadians:self.heading.y];
  //  CGFloat zVec = [[self class] degreesToRadians:self.heading.z];
    
    CGFloat rawHeading = [self rawHeadingFromX:xVec Y:yVec];
   // CGFloat rawHeadingAngle = -[[self class] degreesToRadians:rawHeading];
    return rawHeading;
}

- (CGFloat) rawHeadingFromX:(CGFloat)xVec Y:(CGFloat)yVec{
    /*
     to obtain this X and Y we really need to use the original mag XYZ and do some kind of matrix multiplication with the rotation matrix for the device.
     Here we are only using the original X and Y values, so this only works if the device is held flat.
     
     //http://stackoverflow.com/questions/11383968/which-ios-class-code-returns-the-magnetic-north/11384054#11384054
     //http://www51.honeywell.com/aero/common/documents/myaerospacecatalog-documents/Defense_Brochures-documents/Magnetic__Literature_Application_notes-documents/AN203_Compass_Heading_Using_Magnetometers.pdf
     */
    
    CGFloat rawHeading = 0;
    if (yVec > 0) rawHeading = 90.0 - atan(xVec/yVec)*180.0/M_PI;
    if (yVec < 0) rawHeading = 270.0 - atan(xVec/yVec)*180.0/M_PI;
    if (yVec == 0 && xVec < 0) rawHeading = 180.0;
    if (yVec == 0 && xVec > 0) rawHeading = 0.0;
    rawHeading -=90;
    
    //added to fix -90 -> 0 being displayed for 270 -> 360
    //may need to remove this
    if (rawHeading < 0) {
        rawHeading +=270;
    }
    
    return rawHeading;
}

#pragma mark - calibration methods

- (IBAction)calibrateLeft:(UIButton *)sender {
    self.calibrationData.left = [[MagnetVector alloc] initWithVector:self.vector];
    NSLog(@"Left Calibrated: %@",self.calibrationData.left);
}

- (IBAction)calibrateMiddle:(UIButton *)sender {
    self.calibrationData.middle = [[MagnetVector alloc] initWithVector:self.vector];
    NSLog(@"Middle Calibrated: %@",self.calibrationData.middle);
}

- (IBAction)calibrateRight:(UIButton *)sender {
    self.calibrationData.right = [[MagnetVector alloc] initWithVector:self.vector];
    NSLog(@"Right Calibrated: %@",self.calibrationData.right);
}

- (IBAction)calibrateBottom:(UIButton *)sender {
    self.calibrationData.bottom = [[MagnetVector alloc] initWithVector:self.vector];
    NSLog(@"Bottom Calibrated: %@",self.calibrationData.bottom);
}

-(BOOL)isCalibrated{
    if ((self.calibrationData.left != nil) &&
        (self.calibrationData.middle != nil) &&
        (self.calibrationData.right != nil) &&
        (self.calibrationData.bottom != nil)){
        return YES;
    }
    return NO;
}

#pragma mark - angle conversions
+ (CGFloat) degreesToRadians:(CGFloat) degrees {return degrees * M_PI / 180;};
+ (CGFloat) radiansToDegrees:(CGFloat) radians {return radians * 180/M_PI;};

#pragma mark - debug methods

-(void)logCalibrationData{
    CGPoint leftXY = [self.calibrationData.left XYpointFromMagnitudeAndDirectionInDegrees];
    CGPoint middleXY = [self.calibrationData.middle XYpointFromMagnitudeAndDirectionInDegrees];
    CGPoint rightXY = [self.calibrationData.right XYpointFromMagnitudeAndDirectionInDegrees];
    CGPoint bottomXY = [self.calibrationData.bottom XYpointFromMagnitudeAndDirectionInDegrees];
    
    NSLog(@"~~~~~~~~~~~CALIBRATED~~~~~~~~~~");
    NSLog(@"left = %.1f,%.1f | middle = %.1f,%.1f | right = %.1f,%.1f | bottom = %.1f,%.1f",leftXY.x,leftXY.y,middleXY.x,middleXY.y,rightXY.x,rightXY.y,bottomXY.x,bottomXY.y);
}

-(void)logDebugData{
    
    // Update the labels with the raw x, y, and z values.
    NSString *Xstring = [NSString stringWithFormat:@"%.1f", self.heading.x];
    NSString *Ystring = [NSString stringWithFormat:@"%.1f", self.heading.y];
    NSString *Zstring = [NSString stringWithFormat:@"%.1f", self.heading.z];
    self.xLabel.text = Xstring;
    self.yLabel.text = Ystring;
    self.zLabel.text = Zstring;
    
    //calculate magnitude of current magnet vector
    CGFloat magnitude = sqrt(self.heading.x*self.heading.x + self.heading.y*self.heading.y + self.heading.z*self.heading.z);
    NSString *magnitudeString = [NSString stringWithFormat:@"%.1f", magnitude];
    
    //calculate direction of current magnet vector
    CGFloat rawHeadingAngleInDeg = [self rawHeadingAngleInDeg];
    
    //calculate curent physical XY location of magnetic pen on paper
    CGPoint paperXY = [self.vector XYpointFromMagnitudeAndDirectionInDegrees];
    
    //log stuff
    //NOTE WE ARE MULTIPLYING paperXY.y by -1 !!!!!!!
    NSLog(@"X = %@, Y = %@, Z = %@, Magnitude = %@, angle = %.1f, paperXY = %.1f,%.1f", Xstring,Ystring,Zstring,magnitudeString,rawHeadingAngleInDeg, paperXY.x, (paperXY.y *-1));
    
}

@end
