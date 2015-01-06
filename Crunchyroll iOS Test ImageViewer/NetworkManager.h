//
//  NetworkingManager.h
//  Crunchyroll iOS Test ImageViewer
//
//  Created by Aditya Narayan on 1/6/15.
//  Copyright (c) 2015 TerryBuOrganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface NetworkManager : NSObject

@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (weak, nonatomic) id delegate;

- (void) getImagesFromCrunchyrollWithDelegate: (id) delegate;

@end




@protocol NetworkManagerDelegate <NSObject>

- (void) didFinishDownloadingImagesFromCrunchyroll;

@end
