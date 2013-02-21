//
//  SPoTRecentPhotosViewController.m
//  CS193P.4.SPoT
//
//  Created by Felix Vigl on 20.02.13.
//  Copyright (c) 2013 Felix Vigl. All rights reserved.
//

#import "SPoTRecentPhotosTVC.h"

@interface SPoTRecentPhotosTVC ()

@end


@implementation SPoTRecentPhotosTVC

@synthesize photoDataDictionaries = _photoDataDictionaries;

- (NSMutableArray *)photoDataDictionaries
{
	if (!_photoDataDictionaries) _photoDataDictionaries = self.history;
	return _photoDataDictionaries;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"History";	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

		//[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
		[self.photoDataDictionaries removeObjectAtIndex:indexPath.row];
		
		[self saveArray:self.photoDataDictionaries];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[self.tableView beginUpdates];
	[self.tableView reloadData];
	[self.tableView endUpdates];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
