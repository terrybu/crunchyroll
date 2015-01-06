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
    
    navbarYOffset = self.navigationController.navigationBar.frame.size.height; //used for adjusting to a little offset in centering due to navbar in portrait
    
    //add tap gesture for toggling nav
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)];
    [self.view addGestureRecognizer:tap];
    
    [self setUpBarButtonsForNav];
    [self showPlaceholderUntilRealImageDownload];
    [self showActivityIndicatorForImageLoading];
    [self downloadAndShowImageAsynchronously];
}


#pragma mark Initial UI Setup
- (void) showActivityIndicatorForImageLoading {
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - navbarYOffset);
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
}

- (void) showPlaceholderUntilRealImageDownload {
    imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"placeHolder"]];
    imageView.contentMode = UIViewContentModeCenter;
    [imageView sizeToFit];
    self.scrollView.contentSize = imageView.bounds.size;
    imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - navbarYOffset);
    [self.scrollView addSubview:imageView];
}


#pragma mark Navigation Bar methods
- (void) setUpBarButtonsForNav {
    UIBarButtonItem *leftMenuButton = [[UIBarButtonItem alloc]initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(goBackToParentTableView)];
    self.navigationItem.leftBarButtonItem = leftMenuButton;
    
    if (self.image.caption && ![self.image.caption isEqualToString:@""]) {
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(showCaption)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
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

- (void) toggleNavigationBar {
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
}



#pragma mark Asynchronous Download Methods

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



#pragma mark Image Alignment Methods
- (void) positionImage: (UIImage *) image{
    self.scrollView.contentSize = image.size;

    if (UIInterfaceOrientationIsPortrait(self.view.window.rootViewController.interfaceOrientation)) {
        [self portraitModeImageViewAlign];
    }
    
    else if (UIInterfaceOrientationIsLandscape(self.view.window.rootViewController.interfaceOrientation)) {
        [self landscapeModeImageViewAlign];
    }
}


- (void) portraitModeImageViewAlign {
    CGPoint midpointOfViewFrame = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-navbarYOffset);
    imageView.center = midpointOfViewFrame;
    
    NSLog(@"*********PORTRAIT****************");
    NSLog(@"imageView x: %f y: %f width: %f height: %f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    NSLog(@"scrollView frame width %f height %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    //when we center an image to the midpoint of the superview,
    //small enough images will be perfectly centered to the frame.
    //however, when image width is greater than the frame width,
    //they will spill over to the left, and alignment will break
    //To remedy this, if we ever find an image-view spilling over, we are going to recenter it according to image size
    
    if (imageView.frame.size.width > self.view.frame.size.width && imageView.frame.size.height > self.view.frame.size.height) {
        //width and height both spillover
        imageView.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
    }
    else if (imageView.frame.size.width > self.view.frame.size.width && imageView.frame.size.height < self.view.frame.size.height) {
        //case of wide images that are not that tall
        imageView.center = CGPointMake(imageView.frame.size.width/2, self.view.frame.size.height/2 - navbarYOffset);
    }
}

- (void) landscapeModeImageViewAlign  {
    CGPoint midpointOfViewFrame = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    imageView.center = midpointOfViewFrame;
    
    NSLog(@"**********LANDSCAPE***************");
    NSLog(@"imageView x: %f y: %f width: %f height: %f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    NSLog(@"scrollView frame width %f height %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    if (imageView.frame.size.width > self.view.frame.size.width && imageView.frame.size.height > self.view.frame.size.height) {
        imageView.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
    }
    
    else if (imageView.frame.size.height > self.view.frame.size.height) {
        imageView.center = CGPointMake(self.view.frame.size.width/2, imageView.frame.size.height/2);
    }
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(self.view.window.rootViewController.interfaceOrientation)) {
        [self landscapeModeImageViewAlign];
    }
    else if (UIInterfaceOrientationIsPortrait(self.view.window.rootViewController.interfaceOrientation)) {
        [self portraitModeImageViewAlign];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
