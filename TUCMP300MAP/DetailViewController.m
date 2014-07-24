//
//  DetailViewController.m
//  TUCMP300MAP
//
//  Created by Shirleen Kneppers on 20/04/2014.
//  Copyright (c) 2014 Shirleen Kneppers. All rights reserved.
//

#import "DetailViewController.h"

#define kArrowDisplayDistanceMin     50.0    // show the arrow at 50 meters

@interface DetailViewController () <UIAlertViewDelegate>
{
    MKPointAnnotation *savedAnnotation;
    UIImageView *arrowView;
}

- (void)hideReturnArrow;
- (void)showReturnArrowAtPoint:(CGPoint)userPoint towards:(CGPoint)returnPoint;
@end

@implementation DetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the "follow user" tracking mode (which can's be set using the attributes inspector
    [_mapView setUserTrackingMode:(MKUserTrackingModeFollow)];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Map

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
	// Force the traking mode to stay either "follow" or "follow with heading"
	// This is important because the subview assumes the user's location is always
	//	centered in the map.
	if (mode==MKUserTrackingModeNone)
		[mapView setUserTrackingMode:MKUserTrackingModeFollow];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	// Delegate method that returns the annotation view object for a given annotation.
    
	// For the user's location annotation, return nil; the map will use the default blue dot.
	if (annotation==self.mapView.userLocation)
		return nil;
	
	// For the only other annotation object, use (or reuse) the standard MKPinAnnotationView object.
	NSString *pinID = @"Save";
	MKPinAnnotationView *view = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
	if (view==nil)
    {
		view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
		view.canShowCallout = YES;
		view.animatesDrop = YES;
		//view.draggable = YES;     // If set, allows the user to move its location
    }
	return view;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	if (savedAnnotation!=nil)
    {
		// There's a savedAnnotation, which means there's something to point at
		
		// Calculate the distance, in meters, between the user's current location and
		//	the saved location. Thankfully, location services will do the math.
		CLLocationCoordinate2D coord = savedAnnotation.coordinate;
		CLLocation *toLoc = [[CLLocation alloc] initWithLatitude:coord.latitude
													   longitude:coord.longitude];
		CLLocationDistance distance = [userLocation.location distanceFromLocation:toLoc];
		if (distance>=kArrowDisplayDistanceMin)
        {
			// The user is far enough away from the saved loction to show the return arrow.
			// Convert the two map coordinates (user and saved) into graphics coordinates
			//	and use those to position and point the arrow.
			CGPoint userPoint = [mapView convertCoordinate:userLocation.coordinate
											 toPointToView:self.mapView];
			CGPoint savePoint = [mapView convertCoordinate:coord
											 toPointToView:self.mapView];
			[self showReturnArrowAtPoint:userPoint towards:savePoint];
			return;
        }
    }
	// Any condition that doesn't result in pointing the arrow should hide it
	[self hideReturnArrow];
}

- (void)hideReturnArrow
{
	arrowView.hidden = YES;
}

- (void)showReturnArrowAtPoint:(CGPoint)userPoint towards:(CGPoint)returnPoint
{
	if (arrowView==nil)
    {
		// Create an image view object with the arrow and layer it immediately on
		//	top of the map view.
		arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
		arrowView.opaque = NO;
		arrowView.alpha = 0.6;
		[self.mapView addSubview:arrowView];
		arrowView.hidden = YES;
    }
	
	// Define a code block that sets the location and rotation of the arrow
	// (UI coordinates are vertically flipped from Cartesian coorindates, so
    //  calculate the angle of (x,-y).)
	CGFloat angle = atan2f(returnPoint.x-userPoint.x,userPoint.y-returnPoint.y);
	CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
	void (^updateArrow)(void) = ^{
		arrowView.center = userPoint;
		arrowView.transform = rotation;
    };
	
	if (arrowView.hidden)
    {
		// The arrow view was previously hidden.
		// Make it appear immediately at the correct location and orientation
		updateArrow();
		arrowView.hidden = NO;
    }
	else
    {
		// Animate the arrow view to its new direction
		[UIView animateWithDuration:0.5 animations:updateArrow];
    }
}

#pragma mark Actions

- (IBAction)dropPin:(id)sender
{
	// Prompt the user for a callout title
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"What's here?"
													message:@"Type a label for this location."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Remember", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.delegate = self;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// The user chose a title for the location: get it and create the annotation
    
	// Get the location of the user (if known)
	CLLocation *location = _mapView.userLocation.location;
	if (location==nil)
		// There is no location available; do nothing
		return;
	
	// Get the name
	NSString *name = [[alertView textFieldAtIndex:0] text];
	name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (name.length==0)
        // User didn't type anything useful; substitute a default
		name = @"Over Here!";
	
	// Clear any existing pin
	[self clearPin:self];
	
	// Create a point annotation and add it to the map
	savedAnnotation = [MKPointAnnotation new];
	savedAnnotation.title = name;
	savedAnnotation.coordinate = location.coordinate;
	[_mapView addAnnotation:savedAnnotation];
	[_mapView selectAnnotation:savedAnnotation animated:YES];
}

- (IBAction)clearPin:(id)sender
{
	if (savedAnnotation!=nil)
    {
		[_mapView removeAnnotation:savedAnnotation];
		savedAnnotation = nil;
    }
}



@end
