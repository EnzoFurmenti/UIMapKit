//
//  UIView+MKAnnotationView.m
//  UIMapKit
//
//  Created by EnzoF on 04.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MKAnnotationView.h>

@implementation UIView (MKAnnotationView)

-(MKAnnotationView* _Nullable )superAnnotationView{
    if([self isKindOfClass:[MKAnnotationView class]])
    {
        return (MKAnnotationView*)self;
    }
    if(!self.superview)
    {
        return nil;
    }
    return [self.superview superAnnotationView];
}

@end
