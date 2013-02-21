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

- (NSArray *)readRecentPhotosList
{
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		return @[];
	}
	NSMutableArray *temp = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
	NSLog(@"read plist");
	if (temp) return temp;
	
	NSLog(@"Error reading plist");
	return @[];
	
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
	
	self.photoDataDictionaries = [self readRecentPhotosList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	self.photoDataDictionaries = [self readRecentPhotosList];
	[self.tableView beginUpdates];
	[self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[self.tableView endUpdates];
}

@end
