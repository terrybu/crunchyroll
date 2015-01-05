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

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            image.imageURL = imageDictionary[@"original"];
            image.thumbnailURL = imageDictionary[@"thumb"];
            image.caption = imageDictionary[@"caption"];
            [self.imagesArray addObject:image];
        }
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = CustomTable
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
