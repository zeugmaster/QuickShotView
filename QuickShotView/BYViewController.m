//
//  BYViewController.m
//  QuickShotView
//
//  Created by Dario Lass on 22.03.13.
//  Copyright (c) 2013 Bytolution. All rights reserved.
//

#import "BYViewController.h"
#import "BYQuickShotView.h"

@interface BYViewController ()

@property (nonatomic, strong) BYQuickShotView *quickShotView;

@end

@implementation BYViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.quickShotView = [[BYQuickShotView alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.quickShotView.frame = CGRectMake(0, 0, 260, 260);
    self.quickShotView.center = self.view.center;
    self.quickShotView.delegate = self;
    [self.view addSubview:self.quickShotView];
    
    // Let's add a little instruction label 
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.font = [UIFont fontWithName:@"Chalkduster" size:20];
    label.text = @"Tap to take snapshot. \nTap again to retake.";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

#pragma mark BYQuickShotViewDelegate implementation

- (void)didTakeSnapshot:(UIImage *)img {
    NSLog(@"BYQuickShotView took a snapshot: %@", img);
}

- (void)didDiscardLastImage {
    NSLog(@"BYQuickShotView did discard the last image taken");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
