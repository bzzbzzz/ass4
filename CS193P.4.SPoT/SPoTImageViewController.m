//
//  SPoTDetailViewController.m
//  CS193P.4.SPoT
//
//  Created by Felix Vigl on 20.02.13.
//  Copyright (c) 2013 Felix Vigl. All rights reserved.
//

#import "SPoTImageViewController.h"
#import "FlickrFetcher.h"

@interface SPoTImageViewController ()

  @property (strong, nonatomic) UIPopoverController *masterPopoverController;

  @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
  @property (strong, nonatomic) UIImageView *imageView;
  @property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
  @property (strong, nonatomic) NSMutableArray *recentPhotos;

- (void)resetImage;

@end

@implementation SPoTImageViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
		[self addToRecentPhotosList:self.detailItem];
        [self resetImage];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)resetImage
{
    // Update the user interface for the detail item.
	[self.activityIndicatorView startAnimating];
	
	if (self.detailItem && self.scrollView) {
		self.scrollView.contentSize = CGSizeZero;
		self.imageView.image = nil;
		
		NSURL *imageURL = [FlickrFetcher urlForPhoto:self.detailItem format:FlickrPhotoFormatLarge];
		
		__block NSData *imageData;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			
			dispatch_semaphore_t _semaphore = dispatch_semaphore_create(0);
			imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
			dispatch_semaphore_signal(_semaphore);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
				UIImage *image = [[UIImage alloc] initWithData:imageData];
				if (image) {
					
					[_activityIndicatorView stopAnimating];
					
					_scrollView.zoomScale = 1.0;
					_scrollView.contentSize = image.size;
					_imageView.image = image;
					
					CGRect frame = { CGPointZero , image.size };
					NSLog(@"\n new CGRect frame:%@ \n ", NSStringFromCGRect(frame));
					
					_imageView.frame = frame;
					NSLog(@"\n self.imageView.frame:%@ \n self.imageView.bounds: %@", NSStringFromCGRect(self.imageView.frame), NSStringFromCGRect(self.imageView.bounds));
				}
				
			});
		});
		
	}
}

- (void)addToRecentPhotosList:(NSDictionary*)detailItem
{
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
	
	NSMutableArray *temp = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
	if (!temp) temp = [[NSMutableArray alloc] init];
	
	[temp removeObject:detailItem];
	[temp insertObject:detailItem atIndex:0];
	if (temp.count > 20) [temp removeLastObject];
	
	[temp writeToFile:plistPath atomically:YES] ? NSLog(@"recentPhotos saved") : NSLog(@"error saving recentPhotos");
	
}

- (UIImageView *)imageView
{
	if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
	if (!_activityIndicatorView) _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	return _activityIndicatorView;
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.scrollView addSubview:self.imageView];
	[self.scrollView addSubview:self.activityIndicatorView];
	self.scrollView.minimumZoomScale = 0.2;
	self.scrollView.maximumZoomScale = 5.0;
	self.scrollView.delegate = self;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	if	(self.imageView.image)	[self.scrollView zoomToRect:self.imageView.bounds animated:YES];
	else						self.activityIndicatorView.center = self.view.center;

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self resetImage];
	
	float heightRatio = (self.scrollView.superview.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - self.navigationController.navigationBar.bounds.size.height) / self.imageView.bounds.size.height;
	float widthRatio = self.scrollView.superview.bounds.size.width / self.imageView.bounds.size.width;
	
	self.scrollView.minimumZoomScale = MIN(heightRatio, widthRatio);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Photos", @"Photos");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
