//
//  ChildViewController.m
//  
//
//  Created by Aditya Narayan on 1/5/15.
//
//

#import "ChildViewController.h"

#define navbarYOffset 50

@interface ChildViewController () {
    
    UIActivityIndicatorView *activityIndicator;
    UIImageView *imageView;
}

@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"placeHolder"]];
    imageView.contentMode = UIViewContentModeCenter;
    [imageView sizeToFit];
    self.scrollView.contentSize = imageView.bounds.size;
    imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
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
    [self showActivityIndicatorUntilImageShowComplete];

    if (self.image.imageURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSError *error;
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.image.imageURL] options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                NSLog(@"Error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
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
                    self.scrollView.contentSize = image.size;
                    imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-navbarYOffset);
                    NSLog(@"scrollView contentsize width %f height %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
                    NSLog(@"scrollView frame width %f height %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                    NSLog(@"imageView x: %f y: %f", imageView.frame.origin.x, imageView.frame.origin.y);
                    NSLog(@"*************************");
                    [activityIndicator stopAnimating];
                });
            }
        });
    }
}

- (void) showActivityIndicatorUntilImageShowComplete {
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.navigationController.navigationBar.frame.origin.y + 30);
    [activityIndicator startAnimating];
    [self.view addSubview: activityIndicator];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
