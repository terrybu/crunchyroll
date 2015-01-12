//
//  Image.h
//  Crunchyroll iOS Test ImageViewer
//
//  Created by Terry Bu on 1/5/15.
//  Copyright (c) 2015 TerryBuOrganization. All rights reserved.

#import <Foundation/Foundation.h>

@interface Image : NSObject

@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *thumbnailURL;
@property (strong, nonatomic) NSString *caption;

@end
