//
//  WBMainViewController.m
//  WBLogEginine
//
//  Created by Robin on 5/26/14.
//  Copyright (c) 2014 Robin. All rights reserved.
//

#import "WBMainViewController.h"
#import "WBDetailViewController.h"
@interface WBMainViewController ()

@end

@implementation WBMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *tmp = [[UIButton alloc]initWithFrame:self.view.bounds];
    [tmp setBackgroundColor:[UIColor brownColor]];
    [tmp addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tmp];
    
    
    // Do any additional setup after loading the view.
}

- (void)btnAction:(id)sender
{
//    @throw [NSException exceptionWithName:@"testCrash" reason:@"for test" userInfo:nil];
    UIViewController *viewController = [[WBDetailViewController new]autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
