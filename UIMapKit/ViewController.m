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
    UIBarButtonItem *addAllStudent = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAllStudent:)];
    //self.navigationItem.rightBarButtonItem = addAllStudent;
    UIBarButtonItem *showAllStudent = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showAllStudent:)];
    self.navigationItem.rightBarButtonItems = @[showAllStudent,addAllStudent];
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
            annotationStudent.sex = currentStudent.sex;
            [mArrayAnnotationStud addObject:annotationStudent];
        }
        _arrayAnnotationStudents = [NSArray arrayWithArray:mArrayAnnotationStud];
    }
    return _arrayAnnotationStudents;
}

#pragma mark - action

-(void)addAllStudent:(UIBarButtonItem*)barButton{
    [self.mapView addAnnotations:self.arrayAnnotationStudents];
}

-(void)showAllStudent:(UIBarButtonItem*)barButton{
    MKMapRect zoomRect = MKMapRectNull;
    static double delta = 20000;
    for (id<MKAnnotation>annotation in self.arrayAnnotationStudents)
    {
        CLLocationCoordinate2D coord = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(coord);
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta*2, delta*2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50.f,50.f,50.F,50.f) animated:YES];
}

#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString *identifier = @"MapAnnotationStudent";
    
    MKAnnotationView *annotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(!annotationView)
    {
        annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        
        BOOL isFemale = YES;
        if([annotation isKindOfClass:[MapAnnotationStudent class]])
        {
            MapAnnotationStudent *mapAnnotationStud = (MapAnnotationStudent*)annotation;
            if(mapAnnotationStud.sex == StudentMale)
            {
                isFemale = NO;
            }
           // NSLog(@" %d %@",isFemale ,isFemale ? @"female.png" : @"male.png");
            UIImage *image = [UIImage imageNamed:isFemale ? @"female.png" : @"male.png"];
            annotationView.image = image;
        }
        annotationView.draggable = YES;
        annotationView.canShowCallout = YES;
    }
    else
    {
        annotationView.annotation = annotation;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState{
    
    if (newState == MKAnnotationViewDragStateStarting) {
        [UIView animateWithDuration:0.3f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                                view.transform = CGAffineTransformMakeScale(2.f, 2.f);
                         }completion:^(BOOL finished) {
                             [view setDragState:MKAnnotationViewDragStateDragging animated:YES];
        }];
    }
    else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling) {
        
        [UIView animateWithDuration:0.3f delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                                    view.transform = CGAffineTransformMakeScale(1.f, 1.f);
                        }completion:^(BOOL finished) {
                            [view setDragState:MKAnnotationViewDragStateNone animated:YES];
        }];
    }
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views{
    
    for (MKAnnotationView *annotationView in views)
    {
        CGRect finishFrame = annotationView.frame;
        annotationView.frame = CGRectOffset(finishFrame, 100, -300);
        [UIView animateWithDuration:0.5
                         animations:^{ annotationView.frame = finishFrame; }];
    }
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
