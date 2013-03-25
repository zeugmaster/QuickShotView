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

//This method returns the AVCaptureDevice we want to use as an input for our AVCaptureSession

- (AVCaptureDevice *)rearCamera {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
        }
    }
    return captureDevice;
}

- (void)prepareSession
{
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
    self.layer.masksToBounds = YES;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer insertSublayer:prevLayer atIndex:0];
}

- (void)captureImage
{
    //Before we can take a snapshot, we need to determine the specific connection to be used
    NSArray *connections = [self.stillImageOutput connections];
    AVCaptureConnection *stillImageConnection;
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) {
				stillImageConnection = connection;
			}
		}
	}
        
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           UIImage *capturedImage;
                                                           if (imageDataSampleBuffer != NULL) {
                                                               // as for now we only save the image to the camera roll, but for reusability we should consider implementing a protocol
                                                               // that returns the image to the object using this view
                                                               NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                               capturedImage = [UIImage imageWithData:imgData];
                                                               UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil);
                                                            }
                                                           NSLog(@"captured image: %@", capturedImage);
                                                       }];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self captureImage];
}


@end
