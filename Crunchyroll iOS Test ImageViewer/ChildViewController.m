//
//  ChildViewController.m
//  
//
//  Created by Aditya Narayan on 1/5/15.
//
//

#import "ChildViewController.h"

@interface ChildViewController ()

@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.image.imageURL) {
        self.imageView.image = [UIImage imageNamed:@"placeHolder"];
        //we are going to check if we already had pushed this image into Cache
        UIImage *imageFromCache = [self.imageCache objectForKey:self.image.imageURL];
        if (imageFromCache) {
            //if we did, then we just get from cache and display
            NSLog(@"loading from cache");
            self.imageView.image = imageFromCache;
        }
        else {
            //if we don't have anything in the cache for this key, that means we gotta get the imageData from URL, create image and push it into Cache
            //this is time-intensive so we are going to download image data in a background thread  using GCD
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSError *error;
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.image.imageURL] options:NSDataReadingMappedIfSafe error:&error];
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                UIImage *image = nil;
                if (imageData) {
                    image = [UIImage imageWithData:imageData];
                }
                if (image) {
                    //now we have a new image. we push this into the cache
                    [self.imageCache setObject:image forKey:self.image.imageURL];
                    //now we are done setting the image in the cache.
                    //But we still need to display this newly made image into the imageview of the cell
                    //we have to make UI changes in the main thread. Go back to main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = image;
                    });
                }
            });
        }
    }

}


- (NSCache *) imageCache {
    if (!_imageCache)
        _imageCache = [[NSCache alloc]init];
    _imageCache.countLimit = 50; //maximum # of objects our cache should hold
    return _imageCache;
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
