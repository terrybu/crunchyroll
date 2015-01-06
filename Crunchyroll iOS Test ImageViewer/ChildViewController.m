//
//  ChildViewController.m
//  
//
//  Created by Aditya Narayan on 1/5/15.
//
//

#import "ChildViewController.h"

@interface ChildViewController () {
    
    UIImageView *imageView;
    UIActivityIndicatorView *activityIndicator;
    int navbarYOffset;
}

@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    navbarYOffset = self.navigationController.navigationBar.frame.size.height;
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - navbarYOffset);
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    
    imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"placeHolder"]];
    imageView.contentMode = UIViewContentModeCenter;
    [imageView sizeToFit];
    self.scrollView.contentSize = imageView.bounds.size;
    imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - navbarYOffset);
    [self.scrollView addSubview:imageView];
    
    //add tap gesture for toggling nav
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    [self.view addGestureRecognizer:tap];
    
    [self setUpBarButtonsForNav];
    [self downloadAndShowImageAsynchronously];
    
}

- (void) setUpBarButtonsForNav {
    UIBarButtonItem *leftMenuButton = [[UIBarButtonItem alloc]initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(goBackToParentTableView)];
    self.navigationItem.leftBarButtonItem = leftMenuButton;
    
    if (self.image.caption && ![self.image.caption isEqualToString:@""]) {
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(showCaption)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
}

- (void) toggleNavigationBar {
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
}

- (void) downloadAndShowImageAsynchronously {
    
    if (self.image.imageURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSError *error;
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.image.imageURL] options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                NSLog(@"Error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator stopAnimating];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Downloading Error"
                                                                    message:@"No image could be downloaded from the URL ... Sorry!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
                return;
            }
            UIImage *image = nil;
            if (imageData) {
                image = [UIImage imageWithData:imageData];
            }
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                    imageView.contentMode = UIViewContentModeCenter;
                    [imageView sizeToFit];
                    [self positionImage: image];
                    [activityIndicator stopAnimating];
                });
            }
        });
    }
}

- (void) positionImage: (UIImage *) image{
    //Portrait Mode
    CGPoint midpointOfViewFrame = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-navbarYOffset);
    imageView.center = midpointOfViewFrame;
    self.scrollView.contentSize = image.size;
    
    NSLog(@"*************************");
    NSLog(@"image size width: %f height: %f", image.size.width, image.size.height);
    NSLog(@"imageView x: %f y: %f width: %f height: %f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    NSLog(@"scrollView contentsize width %f, height %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    NSLog(@"scrollView frame width %f height %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    //when we center an image to the midpoint of the superview,
    //small enough images will be perfectly centered to the frame.
    //however, when image width is greater than the frame width,
    //they will spill over to the left, and since contentSize starts from (0,0) towards the right,
    //user won't be able to scroll-over to the image spillage to the left
    //To remedy this, if we ever find an image-view spilling over, we are going to recenter it according to contentsize
    if (image.size.width > self.view.frame.size.width && image.size.height > self.view.frame.size.height) {
        //case of huge images with both width/height
        imageView.center = CGPointMake(self.scrollView.contentSize.width/2, self.scrollView.contentSize.height/2);
    }
    else if (image.size.width > self.view.frame.size.width && image.size.height < self.view.frame.size.height) {
        //case of wide images that are not that tall
        imageView.center = CGPointMake(self.scrollView.contentSize.width/2, self.view.frame.size.height/2-navbarYOffset);
    }
    
    //Landscape Mode
    
    //                    if (UIInterfaceOrientationIsLandscape(self.view.window.rootViewController.interfaceOrientation)) {
    

    
}

- (void) goBackToParentTableView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showCaption {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caption"
                                                    message:self.image.caption
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(self.view.window.rootViewController.interfaceOrientation)) {
        
        NSLog(@"current frame width: %f, current frame height: %f", self.view.frame.size.width, self.view.frame.size.height);
        navbarYOffset = self.navigationController.navigationBar.frame.size.height;
        
        CGPoint midpointOfViewFrame = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + self.navigationController.navigationBar.frame.size.height);
        imageView.center = midpointOfViewFrame;
        if (imageView.frame.size.height + navbarYOffset >= self.view.frame.size.height) {
            NSLog(@"change content size height to accomodate the image height");
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, imageView.frame.size.height + navbarYOffset);
        }
    }
    else if (UIInterfaceOrientationIsPortrait(self.view.window.rootViewController.interfaceOrientation)) {
        CGPoint midpointOfViewFrame = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - navbarYOffset);
        imageView.center = midpointOfViewFrame;
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
