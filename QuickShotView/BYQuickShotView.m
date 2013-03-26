//
//  BYQuickShotView.m
//  QuickShotView
//
//  Created by Dario Lass on 22.03.13.
//  Copyright (c) 2013 Bytolution. All rights reserved.
//

#import "BYQuickShotView.h"
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>

@interface BYQuickShotView ()

- (void)prepareSession;
- (AVCaptureDevice*)rearCamera;
- (void)captureImage;
- (CGRect)previewLayerFrame;
- (UIImage*)cropImage:(UIImage*)imageToCrop;
- (void)buttonPressed;
- (CGRect)buttonFrame;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIImageView *imagePreView;

@end

#define PREVIEW_LAYER_INSET 8
#define PREVIEW_LAYER_EDGE_RADIUS 10
#define BUTTON_SIZE 50

@implementation BYQuickShotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareSession];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIButton *)button {
    if (!_button)  {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        _button.layer.masksToBounds = YES;
        _button.layer.cornerRadius = 5;
        _button.frame = CGRectMake((self.bounds.size.width/2) - (BUTTON_SIZE/2), self.bounds.size.height-(BUTTON_SIZE+20), BUTTON_SIZE, BUTTON_SIZE);
        [_button setImage:[UIImage imageNamed:@"cam.png"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UIImageView *)imagePreView
{
    if (!_imagePreView) {
        _imagePreView = [[UIImageView alloc]init];
        _imagePreView.layer.cornerRadius = PREVIEW_LAYER_EDGE_RADIUS;
        _imagePreView.layer.masksToBounds = YES;
        _imagePreView.frame = self.previewLayerFrame;
        [self insertSubview:_imagePreView belowSubview:self.button];
    }
    return _imagePreView;
}

- (CGRect)previewLayerFrame
{
    CGRect layerFrame = self.bounds;
    
    layerFrame.origin.x += PREVIEW_LAYER_INSET;
    layerFrame.origin.y += PREVIEW_LAYER_INSET;
    layerFrame.size.width -= PREVIEW_LAYER_INSET * 2;
    layerFrame.size.height -= PREVIEW_LAYER_INSET * 2;
    
    return layerFrame;
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

// if we want to add a shadow without drawing out of bounds we have to slightly resize the AVCaptureVideoPreviewLayer
// and this method returns trhe frame we need to achieve this



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

- (void)didMoveToSuperview
{
    AVCaptureVideoPreviewLayer *prevLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    prevLayer.frame = self.previewLayerFrame;
    prevLayer.masksToBounds = YES;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    prevLayer.cornerRadius = PREVIEW_LAYER_EDGE_RADIUS;
    [self.layer insertSublayer:prevLayer atIndex:0];
    [self addSubview:self.button];
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
                                                            }
                                                           UIImage *croppedImg = [self cropImage:capturedImage];
                                                           self.imagePreView.image = croppedImg;
                                                           self.currentImage = croppedImg;
                                                        }];
}

- (void)buttonPressed
{
    if (!self.currentImage) {
        [self captureImage];
        [_button setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    } else {
        self.imagePreView.image = nil;
        self.currentImage = nil;
        [_button setImage:[UIImage imageNamed:@"cam.png"] forState:UIControlStateNormal];
    }

}

- (UIImage *)cropImage:(UIImage *)imageToCrop {
    CGSize size = [imageToCrop size];
    int padding = 0;
    int pictureSize;
    int startCroppingPosition;
    if (size.height > size.width) {
        pictureSize = size.width - (2.0 * padding);
        startCroppingPosition = (size.height - pictureSize) / 2.0;
    } else {
        pictureSize = size.height - (2.0 * padding);
        startCroppingPosition = (size.width - pictureSize) / 2.0;
    }
    CGRect cropRect = CGRectMake(startCroppingPosition, padding, pictureSize, pictureSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:imageToCrop.imageOrientation];
    return newImage;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat minx = CGRectGetMinX(self.previewLayerFrame), midx = CGRectGetMidX(self.previewLayerFrame), maxx = CGRectGetMaxX(self.previewLayerFrame);
    CGFloat miny = CGRectGetMinY(self.previewLayerFrame), midy = CGRectGetMidY(self.previewLayerFrame), maxy = CGRectGetMaxY(self.previewLayerFrame);
    CGContextMoveToPoint(c, minx, midy);
    CGContextAddArcToPoint(c, minx, miny, midx, miny, PREVIEW_LAYER_EDGE_RADIUS);
    CGContextAddArcToPoint(c, maxx, miny, maxx, midy, PREVIEW_LAYER_EDGE_RADIUS);
    CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, PREVIEW_LAYER_EDGE_RADIUS);
    CGContextAddArcToPoint(c, minx, maxy, minx, midy, PREVIEW_LAYER_EDGE_RADIUS); 
    CGContextClosePath(c);
    CGContextSetShadow(c, CGSizeMake(0, 0), 6);
    CGContextSetLineWidth(c, 4);
    CGContextSetStrokeColorWithColor(c, [[UIColor whiteColor] CGColor]);
    CGContextDrawPath(c, kCGPathFillStroke);
}

@end
