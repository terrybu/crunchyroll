//
//  HomeTableViewController.m
//  
//
//  Created by Aditya Narayan on 1/5/15.
//
//

#import "HomeTableViewController.h"
#import "CustomTableViewCell.h"
#import <AFNetworking.h>
#import "Image.h"

@interface HomeTableViewController ()

@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSCache * imageCache;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageCache = [[NSCache alloc] init];
    self.imageCache.countLimit = 50; //maximum # of objects our cache should hold
    
    AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
    
    //without setting acceptable content types, AFNetworking throws validation error ... "text/plain" needs to be set like below
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [httpManager GET:@"http://dl.dropbox.com/u/89445730/images.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *imagesArray = responseObject;
        NSLog(@"%lu images are in the images array", (unsigned long)imagesArray.count);
        //loop through the images Array and look at every image
        for (int i=0; i < imagesArray.count; i++) {
            NSDictionary *imageDictionary = imagesArray[i];
            Image *image = [[Image alloc]init];
            image.imageURL = [self returnStringIfNotNull:@"original" NSDictionary:imageDictionary];
            image.thumbnailURL = [self returnStringIfNotNull:@"thumb" NSDictionary:imageDictionary];
            image.caption = [self returnStringIfNotNull:@"caption" NSDictionary:imageDictionary];
            [self.imagesArray addObject:image];
        }
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSString *) returnStringIfNotNull: (NSString *) key NSDictionary: (NSDictionary *) imageDictionary{
    if ([imageDictionary[key] isKindOfClass:[NSNull class]])
        return nil;
    else
        return (NSString *) imageDictionary[key];

    return nil;
}

//lazy instantiation
- (NSMutableArray *) imagesArray {
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc]init];
    }
    return _imagesArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.imagesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    CustomTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...

    Image *imageObject = self.imagesArray[indexPath.row];
    if (imageObject.caption)
        cell.captionLabel.text = imageObject.caption;

    if (imageObject.thumbnailURL) {
        cell.thumbnailImageView.image = [UIImage imageNamed:@"placeHolder"];
        //we are going to check if we already had pushed this image into Cache
        UIImage *imageFromCache = [self.imageCache objectForKey:imageObject.thumbnailURL];
        if (imageFromCache) {
            //if we did, then we just get from cache and display
            cell.thumbnailImageView.image = imageFromCache;
        }
        else {
            //if we don't have anything in the cache for this key, that means we gotta get the imageData from URL, create image and push it into Cache
            //this is time-intensive so we are going to download image data in a background thread  using GCD
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSError *error;
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageObject.thumbnailURL] options:nil error:&error];
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                UIImage *image = nil;
                if (imageData) {
                    image = [UIImage imageWithData:imageData];
                }
                if (image) {
                    //now we have a new image. we push this into the cache
                    [self.imageCache setObject:image forKey:imageObject.thumbnailURL];
                    //now we are done setting the image in the cache.
                    //But we still need to display this newly made image into the imageview of the cell
                    //we have to make UI changes in the main thread. Go back to main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
                        cell.thumbnailImageView.image = image;
                    });
                }
            });
        }
    }
    NSLog(imageObject.imageURL);
    return cell;
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
