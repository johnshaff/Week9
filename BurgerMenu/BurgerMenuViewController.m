//
//  BurgerMenuViewController.m
//  BurgerMenu
//
//  Created by John Shaff on 12/12/16.
//  Copyright © 2016 John Shaff. All rights reserved.
//

#import "BurgerMenuViewController.h"

CGFloat kBurgerOpenScreenBoundary = 0.33; //value 0.0-1.0
CGFloat kBurgerRevealWidth = 0.25; //value 0.0-1.0

CGFloat kBurgerImageWidth = 50.0;
CGFloat kBurgerImageHeigth = 50.0;

NSTimeInterval kAnimationSlideMenuOpenTime = 0.25;
NSTimeInterval kAnimationSlideMenuCloseTime = 0.15;



@interface BurgerMenuViewController () <UITableViewDelegate>

//We need an array of view controllers
@property(strong, nonatomic) NSArray *viewControllers;

//Need to have access to top view controller at all times in order to move the burger menu image to a viewable vc.
@property(strong, nonatomic) UIViewController *topViewController;

@property(strong, nonatomic) UIButton *burgerButton;
@property(strong, nonatomic) UIPanGestureRecognizer *panGesture;




@end

@implementation BurgerMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *VC1 = [self.storyboard instantiateViewControllerWithIdentifier:@"VC1"];
    UIViewController *VC2 = [self.storyboard instantiateViewControllerWithIdentifier:@"VC2"];
    
    //An array litteral, just like a string literal, a short hand version of alloc init, but here created an array with these two
    self.viewControllers = @[VC1, VC2];
    self.topViewController = self.viewControllers.firstObject;
    


    UITableViewController *menuTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuTable"];
    
    //Making the VC1 & 2 the children of BurgerMenuViewController
    [self setupChildController:menuTableViewController];
    [self setupChildController:VC1];
    
    
    menuTableViewController.tableView.delegate = self;
    
    //MARK: Dispatch Homework
    dispatch_queue_t dispatchQueue = dispatch_queue_create("dispatchQueue", nil);
    dispatch_async(dispatchQueue, ^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self setupBurgerButton];
            [self setupPanGesture];
            
        });
    });

}


-(void)setupChildController:(UIViewController *)childViewController{
    
    [self addChildViewController:childViewController];
    
    childViewController.view.frame = self.view.frame;
    
    [self.view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
    
}

-(void)setupBurgerButton{
    
    CGFloat padding = 20.0;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(padding, padding, kBurgerImageWidth, kBurgerImageHeigth)];
    
    [button setImage:[UIImage imageNamed:@"burger"] forState:UIControlStateNormal];
    
    [self.topViewController.view addSubview:button];
    
    [button addTarget:self action:@selector(burgerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.burgerButton = button;
    
}


-(void)setupPanGesture{
    
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(topViewControllerPanned:)];
    [self.topViewController.view addGestureRecognizer:self.panGesture];
    
}

-(void)topViewControllerPanned:(UIPanGestureRecognizer *)sender{
    CGPoint velocity = [sender velocityInView:self.topViewController.view];
    CGPoint translation = [sender translationInView:self.topViewController.view];
    
    NSLog(@"%f", velocity.x);
    NSLog(@"%f", translation.x);

    
    //any time the state changes, aka when the pan moves across the screen
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        if (translation.x >= 0) {
            self.topViewController.view.center = CGPointMake(self.topViewController.view.center.x + translation.x, self.view.center.y);
            
            [sender setTranslation:CGPointZero inView:self.topViewController.view];
            
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        __weak typeof(self) bruceBanner = self;
        
        if (self.topViewController.view.frame.origin.x > self.view.frame.size.width * kBurgerOpenScreenBoundary) {

            
            [UIView animateWithDuration:kAnimationSlideMenuOpenTime animations:^{
                __strong typeof(bruceBanner) hulk = bruceBanner;

                hulk.topViewController.view.center = CGPointMake(hulk.view.center.x / kBurgerImageWidth, hulk.view.center.y);
                
            } completion:^(BOOL finished) {
                __strong typeof(bruceBanner) hulk = bruceBanner;

                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:hulk action:@selector(tapToCloseMenu:)];
                
                [hulk.topViewController.view addGestureRecognizer:tapGesture];
                hulk.burgerButton.userInteractionEnabled = NO;
                
            }];
            
        } else {
            
            [UIView animateWithDuration:kAnimationSlideMenuOpenTime animations:^{
                __strong typeof(bruceBanner) hulk = bruceBanner;
                
                hulk.topViewController.view.center = hulk.view.center;
                
            }];
        }
    }
}


-(void)burgerButtonPressed:(UIButton *)sender{
    
    __weak typeof(self) bruceBanner = self;
    
    [UIView animateWithDuration:kAnimationSlideMenuOpenTime animations:^{
        
        __strong typeof(bruceBanner) hulk = bruceBanner;

        
        hulk.topViewController.view.center = CGPointMake(hulk.view.center.x / kBurgerRevealWidth, hulk.view.center.y);
    } completion:^(BOOL finished) {
        
        __strong typeof(bruceBanner) hulk = bruceBanner;
        
        UITapGestureRecognizer *tapToClose = [[UITapGestureRecognizer alloc]initWithTarget:hulk action:@selector(tapToCloseMenu:)];
        
        [hulk.topViewController.view addGestureRecognizer:tapToClose];
        
        sender.userInteractionEnabled = NO;
    }];
    
}

-(void)tapToCloseMenu:(UITapGestureRecognizer *)sender {
    [self.topViewController.view removeGestureRecognizer:sender];
    
    __weak typeof(self) bruceBanner = self;
    
    [UIView animateWithDuration:kAnimationSlideMenuOpenTime animations:^{
        
        __strong typeof(bruceBanner) hulk = bruceBanner;
        
        hulk.topViewController.view.center = self.view.center;
    } completion:^(BOOL finished) {
        
        __strong typeof(bruceBanner) hulk = bruceBanner;
        
        hulk.burgerButton.userInteractionEnabled = YES;
    }];
}

//MARK: UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIViewController *newTopViewController = self.viewControllers[indexPath.row];
    
    
    //MARK: NSError Homework
    if (newTopViewController != nil) {
        
        NSString *domain = @"CheckForControllers";
        NSInteger code = 1;
        NSDictionary *userInfo = @{@"Description" : @"Controllers Not found."};

        NSError *error = [NSError errorWithDomain:domain
                                             code:code
                                         userInfo:userInfo];
        
        NSLog(@"%@", error.localizedDescription);
    }
    
    __weak typeof(self) bruceBanner = self;
    
    [UIView animateWithDuration:kAnimationSlideMenuOpenTime animations:^{
        
        __strong typeof(bruceBanner) hulk = bruceBanner;
        
        hulk.topViewController.view.frame = CGRectMake(hulk.view.frame.size.width,
                                                       hulk.view.frame.origin.y,
                                                       hulk.view.frame.size.width,
                                                       hulk.view.frame.size.height);

    } completion:^(BOOL finished) {
        
        __strong typeof(bruceBanner) hulk = bruceBanner;
        
        CGRect oldFrame = hulk.topViewController.view.frame;
        
        [hulk.topViewController willMoveToParentViewController:nil];
        [hulk.topViewController.view removeFromSuperview];
        [hulk.topViewController removeFromParentViewController];
        
        [hulk setupChildController:newTopViewController];
        newTopViewController.view.frame = oldFrame;
        hulk.topViewController = newTopViewController;
        
        [hulk.burgerButton removeFromSuperview];
        [hulk.topViewController.view addSubview:hulk.burgerButton];
        
        
        
        [UIView animateWithDuration:kAnimationSlideMenuCloseTime animations:^{
            hulk.topViewController.view.frame = hulk.view.frame;
        } completion:^(BOOL finished) {
            [hulk.topViewController.view addGestureRecognizer:hulk.panGesture];
            hulk.burgerButton.userInteractionEnabled = YES;
        }];

    }];
}


@end
