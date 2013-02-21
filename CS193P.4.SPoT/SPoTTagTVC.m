//
//  SPoTTagViewController.m
//  CS193P.4.SPoT
//
//  Created by Felix Vigl on 20.02.13.
//  Copyright (c) 2013 Felix Vigl. All rights reserved.
//

#import "SPoTTagTVC.h"
#import "FlickrFetcher.h"

@interface SPoTTagTVC ()

  @property (strong, nonatomic) NSArray *photoDataDictionaries;
  @property (strong, nonatomic) NSMutableDictionary *tags;
  @property (strong, nonatomic) NSArray *sortedTags;

@end

@implementation SPoTTagTVC

#define EXPECTED_NUMBER_OF_TAGS 50

  @synthesize tags = _tags;

- (void)setPhotoDataDictionaries:(NSArray *)photoDataDictionaries
{
	if (![_photoDataDictionaries isEqualToArray:photoDataDictionaries]) {
		
		_photoDataDictionaries = photoDataDictionaries;
		[self generateListOfTags];
	}
	
	[self performSelector:@selector(stopRefreshing) withObject:nil afterDelay:0.5];
}

- (NSMutableDictionary *)tags
{
	if (!_tags) _tags = [[NSMutableDictionary alloc] initWithCapacity:EXPECTED_NUMBER_OF_TAGS];
	return _tags;
}
- (void)setTags:(NSMutableDictionary *)tags
{
	if (![_tags isEqualToDictionary:tags]) {
		_tags = tags;
	}
}

- (NSArray *)sortedTags
{
	if (!_sortedTags) _sortedTags = [[NSArray alloc] init];
	return _sortedTags;
}

- (void)generateListOfTags {
	
	NSArray *tagsNotToInclude = @[@"cs193pspot", @"portrait", @"landscape"];
	
	for (NSDictionary *photoDataDictionary in self.photoDataDictionaries) {
		
		NSArray *tagsOfPhoto = [[photoDataDictionary valueForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
		for (NSString *photoTag in tagsOfPhoto) {
			
			if (![tagsNotToInclude containsObject:photoTag]) {

				if ([[self.tags allKeys] containsObject:photoTag]) {
					[self.tags[photoTag] addObject:photoDataDictionary];
				}else{
					NSMutableArray *photos = [NSMutableArray arrayWithObject:photoDataDictionary];
					[self.tags setValue:photos forKey:photoTag];
				}
			}
		}
	}
	
	self.sortedTags = [[self.tags allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	[self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

	return self.sortedTags.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSString *tag = self.sortedTags[indexPath.row];
	cell.textLabel.text = [tag capitalizedString];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%i photos",[self.tags[tag] count]];
    // Configure the cell...
    
    return cell;
}

- (void)setupRefreshControl
{
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refreshControl;
	[self.refreshControl beginRefreshing];
}

- (void)refresh
{
	//set the title while refreshing
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing the TableView"];
    //set the date and time of refreshing
    NSDateFormatter *formattedDate = [[NSDateFormatter alloc]init];
    [formattedDate setDateFormat:@"MMM d, h:mm a"];
    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[formattedDate stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
	
	__block NSArray *newPhotos = @[];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		newPhotos = [FlickrFetcher stanfordPhotos];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			self.photoDataDictionaries = newPhotos;
			
		});
	});
}

- (void)showActivityIndicator
{
	CGPoint newOffset = CGPointMake(0, -60);//[self.tableView contentInset].top);
	[self.tableView setContentOffset:newOffset animated:YES];
}

- (void)stopRefreshing
{
	if (self.refreshControl.refreshing) {
		[self.refreshControl endRefreshing];
		[self.tableView setContentOffset:CGPointZero animated:YES];
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Navigation logic may go here. Create and push another view controller.
    
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		//        NSDate *object = _objects[indexPath.row];
        //self.detailViewController.detailItem = object;
    }
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTitles"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSMutableArray *photoDictionaries = [self.tags[self.sortedTags[indexPath.row]] mutableCopy];
        [[segue destinationViewController] setPhotoDataDictionaries:photoDictionaries];
		[[segue destinationViewController] setTitle:self.sortedTags[indexPath.row]];
    }
}



#pragma mark - ViewController Lifecycle


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = @"Tags";
	[self setupRefreshControl];
	[self refresh];

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
