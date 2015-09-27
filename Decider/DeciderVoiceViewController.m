//
//  DeciderVoiceViewController.m
//  Decider
//
//  Created by Howie Li on 6/17/14.
//  Copyright (c) 2014 me.howieli. All rights reserved.
//

#import "DeciderVoiceViewController.h"

@interface DeciderVoiceViewController ()

@end

@implementation DeciderVoiceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Voice"];
    
    // about style
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES; // should always be yes or layout will be disordered
    
    // this will appear as the title in the navigation bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightTextColor]; // change this color
    
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"DECIDER", @"");
    [label sizeToFit];

}


@end
