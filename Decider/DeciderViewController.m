//
//  DeciderViewController.m
//  Decider
//
//  Created by Howie Li on 6/7/14.
//  Copyright (c) 2014 me.howieli. All rights reserved.
//

#import "DeciderViewController.h"
#import "AMTagListView.h"

@interface DeciderViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet AMTagListView *tagListView;

@property (strong, nonatomic) AMTagView *selection;
@property (strong, nonatomic) AMTagView *tagView;
@property (strong, nonatomic) NSString *chosenTagText;
@property (strong, nonatomic) NSNotificationCenter *orientationNotification;
@property (strong, nonatomic) UIButton *clearButton, *executeButton, *helpButton;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *collision;
@property (strong, nonatomic) UIGravityBehavior *gravityDown;

@end


@implementation DeciderViewController

BOOL isExecuted;



- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.tagListView];
    }
    return _animator;
}

- (UICollisionBehavior *)collision
{
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
    }
    return _collision;
}

- (UIGravityBehavior *)gravityDown
{
    if (!_gravityDown) {
        _gravityDown = [[UIGravityBehavior alloc] init];
        _gravityDown.magnitude = 0.6f;
    }
    return _gravityDown;
}


- (void)clear:(id)sender {
    [self resetAnimation];
    [self.tagListView removeAllTags];
    // remember update isExecuted
    isExecuted = false;
    [self updateAllButtonsStatus];
}

- (void)displayHelp {
    NSString *helpInfo = NSLocalizedString(@"HelpInfo", nil);
    UIAlertView *helpView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HelpTitle", nil)
                                                        message:helpInfo
                                                        delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"HelpButtonTitle", nil)
                                              otherButtonTitles:nil, nil];
//    NSArray *subViewArray = helpView.subviews;
//    for (int x = 0; x < [subViewArray count]; ++x) {
//        if ([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]]) {
//            UILabel *label = [subViewArray objectAtIndex:x];
//            label.textAlignment = NSTextAlignmentRight;
//        }
//    }
    
    [helpView show];
}

- (void)execute
{
    if ([self.tagListView.tags count] <= 1 || isExecuted) {
        return;
    }
    self.chosenTagText = [self decideWhichOneToChoose];
    
    for (AMTagView *tag in self.tagListView.tags) {
        if (tag.tagText != self.chosenTagText) {
            [self.gravityDown addItem:tag];
            [self.collision addItem:tag];
        }
    }
    [self.animator addBehavior:self.gravityDown];
    [self.animator addBehavior:self.collision];
    
    isExecuted = true;
    [self deactivateExecuteButton];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSThread sleepForTimeInterval:0.7];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat tabBarViewWidth = screenWidth;
    CGFloat tabBarViewHeight = 50;
    CGRect tabBarViewRect = CGRectMake(0.0, screenHeight-tabBarViewHeight, tabBarViewWidth, tabBarViewHeight);
    UIView *tabBarView = [[UIView alloc] initWithFrame:tabBarViewRect];
    [tabBarView setBackgroundColor:[UIColor lightTextColor]];
//    tabBarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    tabBarView.layer.borderWidth = 0.3f;
    
    CGFloat buttonWidth = 110;
    CGFloat buttonHeight = tabBarViewHeight;
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clearButton.frame = CGRectMake(0.0, 0.0, buttonWidth, buttonHeight);
    [self.clearButton addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSString *helpButtonImageName = @"helpButtonActiveImage.png";
    self.helpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.helpButton.frame = CGRectMake(tabBarViewWidth-buttonWidth, 0.0, buttonWidth, buttonHeight);
    [self.helpButton setImage:[[UIImage imageNamed:helpButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.helpButton addTarget:self action:@selector(displayHelp) forControlEvents:UIControlEventTouchUpInside];

    self.executeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.executeButton.frame = CGRectMake(0.0+buttonWidth, 0.0, tabBarViewWidth-2*buttonWidth, buttonHeight);
    [self.executeButton addTarget:self action:@selector(execute) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateAllButtonsStatus];
    
    [tabBarView addSubview:self.clearButton];
    [tabBarView addSubview:self.helpButton];
    [tabBarView addSubview:self.executeButton];

    [self.view addSubview:tabBarView];

    
    
    // about style
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES; // should always be yes or layout will be disordered
    
    // this will appear as the title in the navigation bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor orangeColor];
    label.textColor = [UIColor colorWithRed:245.0/255.0 green:141.0/255.0 blue:26.0/255.0 alpha:1.0];
    label.text = NSLocalizedString(@"NavigationBarTitle", Nil);

    [label sizeToFit];
    
    self.navigationItem.titleView = label;
    
    self.textField.font = [UIFont systemFontOfSize:17.0];
    self.textField.placeholder = NSLocalizedString(@"TextFieldPlaceholder", nil);
    
    [self.textField setDelegate:self];

    // set AmTagView appearance
    
    [[AMTagView appearance] setTagColor:[UIColor brownColor]];
    [[AMTagView appearance] setTextFont:[UIFont systemFontOfSize:17.0]];
    
    // set what to do when tapping a tagView(candidate)
    __weak DeciderViewController *weakSefl = self;
    [self.tagListView setTapHandler:^(AMTagView *view){
        weakSefl.selection = view;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[NSString stringWithFormat:@"是否移除选项 “%@” ？", [view tagText]]
                                                           delegate:weakSefl
                                                  cancelButtonTitle:@"否"
                                                  otherButtonTitles:@"是", nil];
        [alertView show];
        
    }];
    
    isExecuted = false;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    self.orientationNotification = [center addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIDevice *device = [UIDevice currentDevice];
        if (device.orientation == UIDeviceOrientationFaceDown && !isExecuted) {
            [self execute];
        }
    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        [self.tagListView removeTag:self.selection];
        [self updateAllButtonsStatus];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; //dismiss keyboard [self.view endEditing:YES]
    if ([self.textField.text length]) {
        [self.tagListView addTag:textField.text];
    }
	[self.textField setText:@""];
    
    [self updateAllButtonsStatus];
    
	return YES;
}

- (void)updateAllButtonsStatus
{
    int numTags = (int)[self.tagListView.tags count];
    UIImage *clearButtonActiveImage = [[UIImage imageNamed:@"clearButtonActiveImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *clearButtonInactiveImage = [[UIImage imageNamed:@"clearButtonInactiveImage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *executeButtonActiveImage = [[UIImage imageNamed:@"executeButtonActiveImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *executeButtonInactiveImage = [[UIImage imageNamed:@"executeButtonInactiveImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if (numTags > 0) {
        self.clearButton.enabled = YES;
        [self.clearButton setImage:clearButtonActiveImage forState:UIControlStateNormal];
    } else {
        self.clearButton.enabled = NO;
        [self.clearButton setImage:clearButtonInactiveImage forState:UIControlStateNormal];
    }
    if (numTags > 1) {
        self.executeButton.enabled = YES;
        [self.executeButton setImage:executeButtonActiveImage forState:UIControlStateNormal];
    } else {
        self.executeButton.enabled = NO;
        [self.executeButton setImage:executeButtonInactiveImage forState:UIControlStateNormal];
    }
}

- (void)deactivateExecuteButton
{
    UIImage *executeButtonInactiveImage = [[UIImage imageNamed:@"executeButtonInactiveImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.executeButton.enabled = NO;
    [self.executeButton setImage:executeButtonInactiveImage forState:UIControlStateNormal];
}


//for shake motion

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self resetAnimation];
        NSArray *tagCopies = [[NSArray alloc] initWithArray:self.tagListView.tags];
        [self.tagListView removeAllTags];
        [tagCopies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[AMTagView class]]) {
                [self.tagListView addTag:((AMTagView *)obj).tagText];
            }
        }];
        // remember update isExecuted
        isExecuted = false;
        [self updateAllButtonsStatus];
    }
}

- (void)resetAnimation
{
    [self.animator removeAllBehaviors];
    for (AMTagView *tag in self.tagListView.tags) {
        if (tag.tagText != self.chosenTagText) {
            [self.gravityDown removeItem:tag];
            [self.collision removeItem:tag];
        }
    }

}


//choose a decision from candidates

- (NSString *)decideWhichOneToChoose
{
    NSUInteger no = arc4random() % [self.tagListView.tags count];
    NSString *chosen = [[self.tagListView.tags objectAtIndex:no] tagText];
    return chosen;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    for (UIView* view in self.view.subviews) {
//        if ([view isKindOfClass:[UITextField class]]) {
//            [view resignFirstResponder];
//        }
//    }
//}

@end