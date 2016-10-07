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
#import "InfoStudentPopover.h"

#import "MapAnnotationStudent.h"
#import "MapAnnotationMeeting.h"
#import "UIView+MKAnnotationView.h"

typedef enum{
    ViewController50km  = 50000,
    ViewController100km = 100000,
    ViewController150km = 150000
}ViewControllerDistance;

typedef NS_ENUM(NSInteger, UISegmentedControlSelectedMode) {
    UISelectedControlSelectedStandard,
    UISelectedControlSelectedHibrid,
    UISelectedControlSelectedSatellite
};

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>


@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *distanceNumberOfStudent;

@property (weak, nonatomic) IBOutlet UITextView *probabilitytTextView;
@property (weak, nonatomic) IBOutlet UIView *probabilityAndEntryView;

@property (nonatomic,strong) InfoStudentPopover *infoStudentPC;
@property (nonatomic,strong) MapAnnotationMeeting *annotationMeeting;

@property (nonatomic,strong) CLGeocoder *geoCoder;
@property (nonatomic,strong) CLLocationManager *locationManager;


@property (nonatomic,strong) MKDirections *directions;

@property (nonatomic,strong) NSArray *arrayStudents;
@property (nonatomic,strong) NSArray *arrayAnnotationStudents;
@property (nonatomic,strong) NSArray *arrayCircleOverlays;


@end

@implementation ViewController

-(void)loadView{
    [super loadView];
    for (UILabel *currentDistance in self.distanceNumberOfStudent)
    {
        currentDistance.text = @"0";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.probabilitytTextView.editable = NO;
    
    UIBarButtonItem *addAllStudent = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAllStudent:)];
    
    UIBarButtonItem *showAllStudent = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showAllStudent:)];
    
    UIBarButtonItem *directionAllStudent = [[UIBarButtonItem alloc]initWithTitle:@"Route" style:UIBarButtonItemStylePlain target:self action:@selector(actionAllDirectionStudent:)];
    
    UIBarButtonItem *reload = [[UIBarButtonItem alloc]initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(actionReload:)];
   
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = @[addAllStudent,flexibleItem,showAllStudent,flexibleItem,reload,flexibleItem,directionAllStudent];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addAnnotation:)];
    UITapGestureRecognizer *doubleTapEmpty = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTapEmpty  .numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    [self.view addGestureRecognizer:doubleTapEmpty];
    [tapGesture requireGestureRecognizerToFail:doubleTapEmpty];

    
    UITapGestureRecognizer *tapProbabilityView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProbability:)];
    [self.probabilitytTextView addGestureRecognizer:tapProbabilityView];
    self.probabilityAndEntryView.layer.borderWidth = 1.f;
    self.probabilityAndEntryView.layer.cornerRadius = 20.f;
    self.probabilityAndEntryView.layer.borderColor = [UIColor blueColor].CGColor;
    
    
    UITapGestureRecognizer *doubleTouchesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowOption:)];
    doubleTouchesTap.numberOfTapsRequired = 1;
    doubleTouchesTap.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:doubleTouchesTap];
    
    self.geoCoder = [[CLGeocoder alloc]init];
    [self startLocation];
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    if([self.geoCoder isGeocoding])
    {
        [self.geoCoder cancelGeocode];
    }
    if([self.directions isCalculating])
    {
        [self.directions cancel];
    }
}

#pragma  mark - lazy initialization
-(NSArray*)arrayStudents{
    if(!_arrayStudents)
    {
        NSMutableArray *mArrayStud = [[NSMutableArray alloc]init];
        NSInteger numbersOfStudent = (arc4random() % 21) + 10;
        
        for (NSInteger n = 0; n <= numbersOfStudent; n++)
        {
            Student *student = [Student randomStudentWithLocation:self.annotationMeeting.coordinate];
            [mArrayStud addObject:student];
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"self.lastName" ascending:YES];
       _arrayStudents =  [mArrayStud sortedArrayUsingDescriptors:@[descriptor]];
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
            annotationStudent.title = [NSString stringWithFormat:@"%@ %@",currentStudent.lastName,currentStudent.firstName];
            annotationStudent.subtitle = [self stringFromDate:currentStudent.dayOfBirth];
            annotationStudent.coordinate = currentStudent.coordStudent;
            annotationStudent.gender = currentStudent.gender;
            annotationStudent.student = currentStudent;
            [mArrayAnnotationStud addObject:annotationStudent];
        }
        _arrayAnnotationStudents = [NSArray arrayWithArray:mArrayAnnotationStud];
    }
    return _arrayAnnotationStudents;
}

-(NSArray*)arrayCircleOverlays{
    if(!_arrayCircleOverlays)
    {
        CLLocationCoordinate2D point2D = self.annotationMeeting.coordinate;
        MKCircle *circle50km = [MKCircle circleWithCenterCoordinate:point2D radius:50000];
        circle50km.title = @"circle50km";
        MKCircle *circle100km = [MKCircle circleWithCenterCoordinate:point2D radius:100000];
        circle100km.title = @"circle100km";
        MKCircle *circle150km = [MKCircle circleWithCenterCoordinate:point2D radius:150000];
        circle150km.title = @"circle150km";
        _arrayCircleOverlays = @[circle50km,circle100km,circle150km];
    }
    return _arrayCircleOverlays;
}
#pragma mark - UIGestureRecognizer
-(void)addAnnotation:(UITapGestureRecognizer*)tap{
    if(!self.annotationMeeting)
    {

        CGPoint tapPoint = [tap locationInView:self.mapView];
        CLLocationCoordinate2D point2D = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
        self.annotationMeeting = [[MapAnnotationMeeting alloc]init];
        self.annotationMeeting.title = @"Meeting point";
        self.annotationMeeting.subtitle = [NSString stringWithFormat:@"N%f°,E%f°",point2D.latitude,point2D.longitude];
        self.annotationMeeting.coordinate = point2D;
        [self.mapView addAnnotation:self.annotationMeeting];
        [self.mapView addOverlays:self.arrayCircleOverlays level:MKOverlayLevelAboveLabels];

    
    }
}

-(void)showProbability:(UITapGestureRecognizer*)tap{
    if([self.probabilitytTextView.text length] > 0)
    {
        NSString*title = @"Вероятности";
        NSString *message = self.probabilitytTextView.text;
        [self showAllertControllerWithMessage:message andTitle:title];
    }
    
}

#pragma mark - action
-(void)actionReload:(UIBarButtonItem*)barButton{
    [self updateEntryAndProbabilityTable];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.annotationMeeting = nil;
    self.arrayCircleOverlays = nil;
    self.arrayAnnotationStudents = nil;
    self.arrayStudents = nil;
    //[self.mapView reloadInputViews];
}

-(void)actionAllDirectionStudent:(UIBarButtonItem*)barButton{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlays:self.arrayCircleOverlays];
    if([self.directions isCalculating])
    {
        [self.directions cancel];
    }
    
    
    BOOL isContainAnnotationStudent = NO;
    for (id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if([annotation isKindOfClass:[MapAnnotationStudent class]])
        {
            isContainAnnotationStudent = YES;
            break;
        }
    }
        if(!isContainAnnotationStudent)
        {
            [self showAllertControllerWithMessage:@"Укажите локации студентов на карте. Для этого нажмите кнопку добавить"andTitle:@"Маршруты не проложены" ];
        }
           __block NSMutableString *errorStr = [[NSMutableString alloc]init];
            for (MapAnnotationStudent *annotationStudent in self.arrayAnnotationStudents)
            {
                CLLocationCoordinate2D coordinate = annotationStudent.coordinate;
                MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
                MKPlacemark *startPlaceMark = [[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:nil];
                request.source = [[MKMapItem alloc] initWithPlacemark:startPlaceMark];
                
                MKPlacemark *finishPlaceMark = [[MKPlacemark alloc]initWithCoordinate:self.annotationMeeting.coordinate addressDictionary:nil];
                request.destination = [[MKMapItem alloc]initWithPlacemark:finishPlaceMark];
                
                request.transportType = MKDirectionsTransportTypeAny;
                self.directions = [[MKDirections alloc]initWithRequest:request];
                [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
                    
                    if(error)
                    {
                        if([errorStr length] ==0)
                        {
                            [errorStr appendString:@"Для  аннотаций:\n"];
                        }
                        [errorStr appendString:[NSString stringWithFormat:@"{%f,%f} %@", annotationStudent.coordinate.longitude,annotationStudent.coordinate.latitude,[error localizedDescription]]];
                    }else{
                        for (MKRoute *route in response.routes)
                        {
                            CLLocationDistance distance = [self distance:annotationStudent];
                            if(distance <= ViewController50km)
                            {
                                route.polyline.title = @"distance50km";
                            }else if(distance <= ViewController100km){
                                route.polyline.title = @"distance100km";
                            }else if(distance <= ViewController150km){
                                route.polyline.title = @"distance150km";
                            }else{
                                route.polyline.title = @"distanceGreateThen150km";
                            }
                            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveLabels];
                        }
                    }
                    
                }];
            }
        if([errorStr length] >0)
        {
            NSLog(@"%@",errorStr);
        }
    
}


-(void)actionShowOption:(UITapGestureRecognizer*)tap{
   self.typeMapControl.hidden = self.typeMapControl.hidden ? NO : YES;


}

- (IBAction)actionMapType:(UISegmentedControl *)sender {

    if(sender.selectedSegmentIndex == UISelectedControlSelectedStandard)
        self.mapView.mapType = MKMapTypeStandard;
    if(sender.selectedSegmentIndex == UISelectedControlSelectedHibrid)
        self.mapView.mapType = MKMapTypeHybrid;
    if(sender.selectedSegmentIndex == UISelectedControlSelectedSatellite)
        self.mapView.mapType = MKMapTypeSatellite;
}

-(void)addAllStudent:(UIBarButtonItem*)barButton{
    if(!self.annotationMeeting)
    {
        NSString*title = @"Студенты не добавлены";
        NSString *message = @"Нажмите на карту,в том месте,где должна быть встреча студентов";
        [self showAllertControllerWithMessage:message andTitle:title];
        
    }
    else
    {
        [self.mapView addAnnotations:self.arrayAnnotationStudents];
    }
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

-(void)actionInfo:(UIButton*)button{
    MKAnnotationView *annotationView = [button superAnnotationView];
    if(annotationView)
    {
        CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
        CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        __block CLPlacemark *placeMark;
        [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if(error)
            {
                if([placemarks count] == 0)
                {
                    NSLog(@"no placeMark");
                }
                    NSLog(@"%@",[error localizedDescription]);
            }
            else
            {
                placeMark = [placemarks firstObject];
                NSString *message =  [self createAdressFromPlacemark:placeMark];
                
                
                self.infoStudentPC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoStudentPopover"];
                self.infoStudentPC.modalPresentationStyle = UIModalPresentationPopover;
                [self presentViewController:self.infoStudentPC animated:YES completion:nil];
                MapAnnotationStudent *mapAnnotationStudent;
                if([annotationView.annotation isKindOfClass:[MapAnnotationStudent class]])
                {
                    mapAnnotationStudent = (MapAnnotationStudent*)annotationView.annotation;
                
                    self.infoStudentPC.firstName.text = mapAnnotationStudent.student.firstName;
                    self.infoStudentPC.lastName.text = mapAnnotationStudent.student.lastName;
        

                    if(mapAnnotationStudent.student.gender == StudentFemale)
                    {
                        [self.infoStudentPC.genderControl setEnabled:NO forSegmentAtIndex:StudentMale];
                        self.infoStudentPC.genderControl.selectedSegmentIndex = StudentFemale;
                    }
                    else
                    {
                        [self.infoStudentPC.genderControl setEnabled:NO forSegmentAtIndex:StudentFemale];
                        self.infoStudentPC.genderControl.selectedSegmentIndex = StudentMale;
                    }
                    
                    self.infoStudentPC.dayOfBirth.text = [self stringFromDate:mapAnnotationStudent.student.dayOfBirth];
                    self.infoStudentPC.address.text = message;
                UIPopoverPresentationController *popoverPresentationC = [self.infoStudentPC popoverPresentationController];
                popoverPresentationC.permittedArrowDirections = UIPopoverArrowDirectionDown;
                popoverPresentationC.sourceView = button;
                }
            }
        }];
    }
    
}

-(NSString*)createAdressFromPlacemark:(CLPlacemark*)placeMark{
    
    NSString *nullMessage = @"нет";
    NSString *message =  [NSString stringWithFormat:@"Название метки %@\n"
                                                    "Улица %@\n"
                                                    "Улица доп. %@\n"
                                                    "Город %@\n"
                                                    "Город доп. %@\n"
                                                    "Область %@\n"
                                                    "Область доп.%@\n"
                                                    "Индекс %@\n"
                                                    "Страна абр %@\n"
                                                    "Страна %@\n"
                                                    "Наименование моря %@\n"
                                                    "Океан %@\n"
                                                    "Достопримечательности %@\n",
                          placeMark.name                    ? placeMark.name                    : nullMessage,
                          placeMark.thoroughfare            ? placeMark.thoroughfare            : nullMessage,
                          placeMark.subThoroughfare         ? placeMark.subThoroughfare         : nullMessage,
                          placeMark.locality                ? placeMark.locality                : nullMessage,
                          placeMark.subLocality             ? placeMark.subLocality             : nullMessage,
                          placeMark.administrativeArea      ? placeMark.administrativeArea      : nullMessage,
                          placeMark.subAdministrativeArea   ? placeMark.subAdministrativeArea   : nullMessage,
                          placeMark.postalCode              ? placeMark.postalCode              : nullMessage,
                          placeMark.ISOcountryCode          ? placeMark.ISOcountryCode          : nullMessage,
                          placeMark.country                 ? placeMark.country                 : nullMessage,
                          placeMark.inlandWater             ? placeMark.inlandWater             : nullMessage,
                          placeMark.ocean                   ? placeMark.ocean                   : nullMessage,
                          placeMark.areasOfInterest         ? placeMark.areasOfInterest         : nullMessage];
    return message;
}

#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    MKAnnotationView *annotationView;
    
    static NSString *identifierStudent = @"MapAnnotationStudent";
    static NSString *identifierMeeting = @"MapAnnotationMeeting";
    
    if([annotation isKindOfClass:[MapAnnotationMeeting class]])
    {
        annotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifierMeeting];
        if(!annotationView)
        {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifierMeeting];
            UIImage *image = [UIImage imageNamed:@"gomer.png"];
            annotationView.image = image;
            UIImageView *imageView = [[UIImageView alloc]initWithImage:annotationView.image];
            annotationView.leftCalloutAccessoryView = imageView;
            annotationView.draggable = YES;
            annotationView.canShowCallout = YES;
            annotationView.layer.zPosition = 3.f;
            
            
            annotationView.layer.shadowColor = [UIColor blackColor].CGColor;
            annotationView.layer.shadowOffset = CGSizeMake(3.f, 2.f);

        }
        else{
            annotationView.annotation = annotation;
        }
        
    }else if([annotation isKindOfClass:[MapAnnotationStudent class]]){
            if(!annotationView)
            {
                annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifierStudent];
                
                BOOL isFemale = YES;
                if([annotation isKindOfClass:[MapAnnotationStudent class]])
                {
                    MapAnnotationStudent *mapAnnotationStud = (MapAnnotationStudent*)annotation;
                    if(mapAnnotationStud.gender == StudentMale)
                    {
                        isFemale = NO;
                    }
                    UIImage *image = [UIImage imageNamed:isFemale ? @"female.png" : @"male.png"];
                    annotationView.image = image;
                }
                
                UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [infoButton addTarget:self action:@selector(actionInfo:) forControlEvents:UIControlEventTouchDown];
                annotationView.rightCalloutAccessoryView = infoButton;
                
                UIImageView *imageView = [[UIImageView alloc]initWithImage:annotationView.image];
                annotationView.leftCalloutAccessoryView = imageView;
                annotationView.canShowCallout = YES;
                annotationView.layer.zPosition = 3.f;
            }
            else{
                annotationView.annotation = annotation;
            }
        [self updateEntryAndProbabilityTable];

    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState{
    [view.superview bringSubviewToFront:view];
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
                            
                            [self.mapView removeOverlays:[self.mapView overlays]];
                            self.arrayCircleOverlays = nil;
                            [self.mapView addOverlays:self.arrayCircleOverlays level:MKOverlayLevelAboveLabels];
                            
                            [self updateEntryAndProbabilityTable];
                        }];
    }
}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    UIColor *color;
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer *renderer;
        MKCircle *circle = (MKCircle*)overlay;
        if([circle.title isEqualToString: @"circle50km"])
        {
            renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
            color = [[UIColor alloc]initWithRed:0.f green:1.f blue:0.f alpha:0.6f];
        }else if([circle.title isEqualToString: @"circle100km"]){
        
            color = [[UIColor alloc]initWithRed:0.f green:1.f blue:0.f alpha:0.4f];
            renderer = [[MKCircleRenderer alloc]initWithCircle:circle];
        }else if([circle.title isEqualToString: @"circle150km"]){
            
            renderer = [[MKCircleRenderer alloc]initWithCircle:circle];
            color = [[UIColor alloc]initWithRed:0.f green:1.f blue:0.f alpha:0.3f];
        }
        renderer.fillColor  = color;
        return renderer;
    }
    else if([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
        if([overlay.title isEqualToString: @"distance50km"])
        {
            color = [[UIColor alloc]initWithRed:0.f green:0.f blue:1.f alpha:0.9f];
            
        }else if([overlay.title isEqualToString: @"distance100km"]){
            
            color = [[UIColor alloc]initWithRed:0.f green:0.f blue:1.f alpha:0.8f];
        }else if([overlay.title isEqualToString: @"distance150km"]){
            
            color = [[UIColor alloc]initWithRed:0.f green:0.f blue:1.f alpha:0.7f];
        }else{
            
            color = [[UIColor alloc]initWithRed:1.f green:0.f blue:0.f alpha:0.5f];
        }
        renderer.lineWidth = 5.f;
        renderer.strokeColor  = color;
        return renderer;
        
    }
    return nil;
}

#pragma mark - entry and probability metods

-(CLLocationDistance)distance:(MapAnnotationStudent*)annotationStudent{
    MKMapPoint a = MKMapPointForCoordinate(annotationStudent.coordinate);
    MKMapPoint b = MKMapPointForCoordinate(self.annotationMeeting.coordinate);
    return  MKMetersBetweenMapPoints(a, b);
}

-(void)entryToDistance:(MapAnnotationStudent*)annotationStudent{
    
    CLLocationDistance distance = [self distance:annotationStudent];
    
    NSInteger tag = 1000;
    
    if(distance <= ViewController50km)
    {
        tag = 50;
    }else if(distance <= ViewController100km){
        tag = 100;
    }else if(distance <= ViewController150km){
        tag = 150;
    }
    for (UILabel *currentDistanceNumberOfStudent in self.distanceNumberOfStudent)
    {
        if(currentDistanceNumberOfStudent.tag == tag)
        {
            NSInteger numberOfStudents = [currentDistanceNumberOfStudent.text integerValue];
            numberOfStudents++;
            currentDistanceNumberOfStudent.text =[ NSString stringWithFormat:@"%ld",(long)numberOfStudents];
        }
    }
}

-(void)probabilityMeeting:(MapAnnotationStudent*)annotationStudent{

    CGFloat(^probabilityMeeting)(double distance) = ^(double distance){
        CGFloat probability;
        if(distance <= ViewController150km)
        {
            probability = ((ViewController150km - distance) / ViewController150km) * 100;
        }
        else
        {
            probability = ((distance - ViewController150km) / distance ) * 10;
        }
        return probability;
    };
    
    MKMapPoint a = MKMapPointForCoordinate(annotationStudent.coordinate);
    MKMapPoint b = MKMapPointForCoordinate(self.annotationMeeting.coordinate);
    CLLocationDistance distance =  MKMetersBetweenMapPoints(a, b);
    
    CGFloat probability = probabilityMeeting(distance);
    if([self.probabilitytTextView.text isEqualToString:@""])
    {
        self.probabilitytTextView.text = [NSString stringWithFormat:@"%@  %1.2f",annotationStudent.title,probability];
    }
    else
    {
        self.probabilitytTextView.text = [NSString stringWithFormat:@"%@  \n%@ %1.2f", self.probabilitytTextView.text, annotationStudent.title, probability];
    }
}

-(void)updateEntryAndProbabilityTable{
    BOOL mapViewContaingStudentAnnotation = NO;
    for(id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if([annotation isKindOfClass:[MapAnnotationStudent class]])
        {
            mapViewContaingStudentAnnotation = YES;
            break;
        }
    }
    if(mapViewContaingStudentAnnotation)
    {
        [self setToZeroTabel];
        self.probabilitytTextView.text = @"";
        for(MapAnnotationStudent *annotationStudent in self.arrayAnnotationStudents)
        {
            [self entryToDistance:annotationStudent];
            [self probabilityMeeting:annotationStudent];
        }
    }
    
}

-(void)setToZeroTabel{
    for (UILabel *currentDistanceNumberOfStudent in self.distanceNumberOfStudent) {
        currentDistanceNumberOfStudent.text = @"0";
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

#pragma mark - other metods

-(void)showAllertControllerWithMessage:(NSString*)message andTitle:(NSString*)title{
    UIAlertController* alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
