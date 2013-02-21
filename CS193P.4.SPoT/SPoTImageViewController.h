//
//  SPoTDetailViewController.h
//  CS193P.4.SPoT
//
//  Created by Felix Vigl on 20.02.13.
//  Copyright (c) 2013 Felix Vigl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPoTImageViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) id detailItem;

@end
