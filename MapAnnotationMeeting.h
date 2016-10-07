//
//  MapAnnotationMeeting.h
//  UIMapKit
//
//  Created by EnzoF on 05.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotationMeeting : NSObject<MKAnnotation>


@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;

@end
