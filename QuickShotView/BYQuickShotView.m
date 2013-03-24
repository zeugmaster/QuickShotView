//
//  BYQuickShotView.m
//  QuickShotView
//
//  Created by Dario Lass on 22.03.13.
//  Copyright (c) 2013 Bytolution. All rights reserved.
//

#import "BYQuickShotView.h"
#import <CoreMedia/CoreMedia.h>

@interface BYQuickShotView ()

- (void)prepareSession;
- (void)captureDeviceBecameAvailible:(NSNotification*)notification;
- (AVCaptureDevice*)rearCamera;
- (void)captureImage;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation BYQuickShotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareSession];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (AVCaptureDevice *)rearCamera {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
        }
    }
    return captureDevice;
}

- (void)prepareSession {

    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.rearCamera error:nil];
    
	
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    
    
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    
    
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddOutput:newStillImageOutput]) {
        [newCaptureSession addOutput:newStillImageOutput];
    }
    
    self.stillImageOutput = newStillImageOutput;
    self.captureSession = newCaptureSession;
    
    [self.captureSession startRunning];

    
    NSLog(@"%@", self.captureSession);
}

- (void)didMoveToSuperview {
    AVCaptureVideoPreviewLayer *prevLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    prevLayer.frame = self.bounds;
    NSLog(@"%@", prevLayer);
    self.layer.masksToBounds = YES;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer insertSublayer:prevLayer atIndex:0];
}

- (void)captureImage
{
    
    NSArray *connections = [self.stillImageOutput connections];
    AVCaptureConnection *stillImageConnection;
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) {
				stillImageConnection = connection;
			}
		}
	}
    
    NSLog(@"%@, %@", stillImageConnection, self.stillImageOutput);
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           UIImage *capturedImage;
                                                           if (imageDataSampleBuffer != NULL) {
                                                           NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                               capturedImage = [UIImage imageWithData:imgData];
                                                               UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil);
                                                            }
                                                           NSLog(@"captured image: %@", capturedImage);
                                                       }];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self captureImage];
    
}


@end
