//
//  ChildViewController.m
//  
//
//  Created by Aditya Narayan on 1/5/15.
//
//

#import "ChildViewController.h"

@interface ChildViewController () {
    
    UIActivityIndicatorView *activityIndicator;

}

@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
        self.imageView.image = [UIImage imageNamed:@"placeHolder"];
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
                    self.imageView.image = image;
                    self.scrollView.contentSize = self.imageView.frame.size;
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
