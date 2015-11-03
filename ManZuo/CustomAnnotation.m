//
//  CustomAnnotation.m
//  ManZuo
//
//  Created by admin on 14-3-6.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

-(id)initWithBranch:(Branch *)branch
{
    self = [super init];
    if (self) {
        self.branch = branch;
    }
    return self;
}

-(NSString *)title
{
    return _title;
}


-(NSString *)subtitle
{
    return _subTitle;
}

-(void)setBranch:(Branch *)branch
{
    _branch = branch;
    _title = _branch.branchName;
    _subTitle = _branch.branchaddress;
    float lat = branch.latitude.floatValue;
    float lon = branch.longitude.floatValue;
    _coordinate = CLLocationCoordinate2DMake(lat, lon);
}

@end
