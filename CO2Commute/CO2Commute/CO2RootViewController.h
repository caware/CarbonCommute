//
//  CO2RootViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLocationController.h"

@class CCLocationController;

@interface CO2RootViewController : UITableViewController <CCLocationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *loggingSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loggingSpinner;
@property (weak, nonatomic) IBOutlet UITextView *_debugText;
@property (nonatomic, assign) CCLocationController *locationController;
@end