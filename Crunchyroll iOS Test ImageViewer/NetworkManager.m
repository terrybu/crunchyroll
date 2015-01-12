//
//  NetworkingManager.m
//  Crunchyroll iOS Test ImageViewer
//
//  Created by Terry Bu on 1/6/15.
//  Copyright (c) 2015 TerryBuOrganization. All rights reserved.
//

#import "NetworkManager.h"
#import "Image.h"

@implementation NetworkManager


- (NSMutableArray *) imagesArray {
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc]init];
    }
    return _imagesArray;
}


- (void) getImagesFromCrunchyrollWithDelegate: delegate {
    
    self.delegate = delegate;
    
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
        [self.delegate didFinishDownloadingImagesFromCrunchyroll];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (NSString *) returnStringIfNotNull: (NSString *) key NSDictionary: (NSDictionary *) imageDictionary{
    if ([imageDictionary[key] isKindOfClass:[NSNull class]])
        return nil;
    else {
        NSString* url = imageDictionary[key];
        return [self returnCorrectParsedURLWithoutLLN:url];
    }
    return nil;
}

- (NSString *) returnCorrectParsedURLWithoutLLN: (NSString *) url {
    return [url stringByReplacingOccurrencesOfString:@"lln." withString:@""];
}


@end
