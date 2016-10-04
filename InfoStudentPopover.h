//
//  InfoStudentPopover.h
//  UIMapKit
//
//  Created by EnzoF on 04.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol InfoStudentPopoverDelegete;

@interface InfoStudentPopover : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UILabel *dayOfBirth;
@property (weak, nonatomic) IBOutlet UITextView *address;

//@property (nonatomic, weak, nullable) id <InfoStudentPopoverDelegete> delegate;

@end

//@protocol InfoStudentPopoverDelegete<NSObject>
//
//@required
//-(void)infoStudentPopoverDelegete:(InfoStudentPopover*)infoStudentPC ;
//
//@end
