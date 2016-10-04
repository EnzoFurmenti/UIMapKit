//
//  InfoStudentPopover.m
//  UIMapKit
//
//  Created by EnzoF on 04.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "InfoStudentPopover.h"

@interface InfoStudentPopover ()<UIPopoverPresentationControllerDelegate>

@end

@implementation InfoStudentPopover


-(void)awakeFromNib{
    [super awakeFromNib];
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverPresentationController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPopoverPresentationControllerDelegate

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection NS_AVAILABLE_IOS(8_3){
    return UIModalPresentationNone;
}
@end
