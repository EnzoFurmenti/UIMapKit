//
//  ViewController.h
//  UIMapKit
//
//  Created by EnzoF on 01.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MKMapView;
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeMapControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)actionMapType:(UISegmentedControl *)sender;


@end

