//
//  ChildViewController.h
//  
//
//  Created by Aditya Narayan on 1/5/15.
//
//

#import <UIKit/UIKit.h>
#import "Image.h"

@interface ChildViewController : UIViewController

@property (strong, nonatomic) Image *image;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
