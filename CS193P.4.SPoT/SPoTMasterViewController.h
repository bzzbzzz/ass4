//
//  SPoTMasterViewController.h
//  CS193P.4.SPoT
//
//  Created by Felix Vigl on 20.02.13.
//  Copyright (c) 2013 Felix Vigl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPoTDetailViewController;

@interface SPoTMasterViewController : UITableViewController

@property (strong, nonatomic) SPoTDetailViewController *detailViewController;

@end
