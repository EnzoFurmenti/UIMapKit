//
//  ViewController.m
//  UIMapKit
//
//  Created by EnzoF on 01.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ViewController.h"
#import "Student.h"
#import "MapAnnotationStudent.h"
@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (strong,nonatomic) CLLocationManager *locationManager;

@property (strong,nonatomic) NSArray *arrayStudents;

@property (strong,nonatomic) NSArray *arrayAnnotationStudents;


@end

@implementation ViewController

-(void)loadView{
    [super loadView];
    self.mapView.showsUserLocation = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocation];
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - lazy initialization
-(NSArray*)arrayStudents{
    if(!_arrayStudents)
    {
        NSMutableArray *mArrayStud = [[NSMutableArray alloc]init];
        NSInteger numbersOfStudent = (arc4random() % 21) + 10;
        MKUserLocation *userLocation = self.mapView.userLocation;
        for (NSInteger n = 0; n <= numbersOfStudent; n++)
        {
            Student *student = [Student randomStudentWithLocation:userLocation.coordinate];
            [mArrayStud addObject:student];
        }

        _arrayStudents = [NSArray arrayWithArray:mArrayStud];
    }
    return _arrayStudents;
}

-(NSArray*)arrayAnnotationStudents{
    if(!_arrayAnnotationStudents)
    {
        NSMutableArray *mArrayAnnotationStud = [[NSMutableArray alloc]init];
        for (Student *currentStudent in self.arrayStudents)
        {
            MapAnnotationStudent *annotationStudent = [[MapAnnotationStudent alloc]init];
            annotationStudent.title = [NSString stringWithFormat:@"%@ %@",currentStudent.firstName,currentStudent.lastName];
            annotationStudent.subtitle = [self stringFromDate:currentStudent.dayOfBirth];
            annotationStudent.coordinate = currentStudent.coordStudent;
            [mArrayAnnotationStud addObject:annotationStudent];
        }
        _arrayAnnotationStudents = [NSArray arrayWithArray:mArrayAnnotationStud];
    }
    return _arrayAnnotationStudents;
}


#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString *identifier = @"MapAnnotationStudent";
    
    MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(!pinAnnotation)
    {
        pinAnnotation = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        pinAnnotation.pinTintColor = [UIColor greenColor];
        pinAnnotation.animatesDrop = YES;
        pinAnnotation.canShowCallout = YES;
    }
    else
    {
        pinAnnotation.annotation = annotation;
    }
    return pinAnnotation;
}


#pragma mark - date metods

-(NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"ru_RU"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"dd MMMM yyyy"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

#pragma mark - CLLocationManagerDelegate
- (void)startLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if(!self.locationManager)
        {
            self.locationManager = [[CLLocationManager alloc] init];
        }
        self.locationManager.delegate = self;

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1000;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager stopUpdatingLocation];
    }
}

@end
