//
//  RCTSensorOrientationChecker.m
//  RCTCamera
//
//  Created by Radu Popovici on 24/03/16.
//
//

#import "RCTSensorOrientationChecker.h"
#import <CoreMotion/CoreMotion.h>


@interface RCTSensorOrientationChecker ()

@property (strong, nonatomic) CMMotionManager * motionManager;
@property (strong, nonatomic) RCTSensorCallback orientationCallback;

@end

@implementation RCTSensorOrientationChecker

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.2;
        self.motionManager.gyroUpdateInterval = 0.2;
        self.orientationCallback = nil;
        self.actualOrientation = UIInterfaceOrientationLandscapeLeft;
        self.actualAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        self.orientation = UIInterfaceOrientationLandscapeLeft;
        
    }
    return self;
}

- (void)dealloc
{
    [self pause];
}

- (void)resume
{
    __weak __typeof(self) weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue new]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 if (!error) {
                                                     self.orientation = [weakSelf getOrientationBy:accelerometerData.acceleration];
                                                 }
                                                 if (self.orientationCallback) {
                                                     self.orientationCallback(self.orientation);
                                                 }
                                             }];
}

- (void)pause
{
    [self.motionManager stopAccelerometerUpdates];
}

- (void)getDeviceOrientationWithBlock:(RCTSensorCallback)callback
{
    __weak __typeof(self) weakSelf = self;
    self.orientationCallback = ^(UIInterfaceOrientation orientation) {
        if (callback) {
            callback(orientation);
        }
        weakSelf.orientationCallback = nil;
        [weakSelf pause];
    };
    [self resume];
}

- (UIInterfaceOrientation)getOrientationBy:(CMAcceleration)acceleration
{
    if(acceleration.x >= 0.75) {
        self.actualOrientation = UIInterfaceOrientationLandscapeLeft;
        return self.actualOrientation;
    }
    if(acceleration.x <= -0.75) {
        self.actualOrientation = UIInterfaceOrientationLandscapeRight;
        return self.actualOrientation;
    }
    if(acceleration.y <= -0.75) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            return self.actualOrientation;
        }
        return UIInterfaceOrientationPortrait;
    }
    if(acceleration.y >= 0.75) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            return self.actualOrientation;
        }
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (AVCaptureVideoOrientation)convertToAVCaptureVideoOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                return self.actualAVCaptureVideoOrientation;
            }
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                return self.actualAVCaptureVideoOrientation;
            }
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            self.actualAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            return self.actualAVCaptureVideoOrientation;
        case UIInterfaceOrientationLandscapeRight:
            self.actualAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            return self.actualAVCaptureVideoOrientation;
        default:
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                return self.actualAVCaptureVideoOrientation;
            }
            return 0;
    }
}

@end
