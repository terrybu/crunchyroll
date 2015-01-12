//
//  HomeTableViewController.h
//  
//
//  Created by Terry Bu on 1/5/15.
//
//

#import <UIKit/UIKit.h>
#import "ChildViewController.h"
#import "NetworkManager.h"

@interface HomeTableViewController : UITableViewController <NetworkManagerDelegate>

@property (strong, nonatomic) NetworkManager *networkManager;

@end
