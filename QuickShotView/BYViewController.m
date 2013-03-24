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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.quickShotView.frame = CGRectMake(30, 50, 260, 260);
    [self.view addSubview:self.quickShotView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
