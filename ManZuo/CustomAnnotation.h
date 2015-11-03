//
//  CustomAnnotation.h
//  ManZuo
//
//  Created by admin on 14-3-6.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Branch.h"

@interface CustomAnnotation : NSObject<MKAnnotation>
{
    NSString *_title;
    NSString *_subTitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Branch *branch;

-(id)initWithBranch:(Branch *)branch;

@end
