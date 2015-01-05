//
//  CustomTableviewCell.h
//  Crunchyroll iOS Test ImageViewer
//
//  Created by Aditya Narayan on 1/5/15.
//  Copyright (c) 2015 TerryBuOrganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;


@end
