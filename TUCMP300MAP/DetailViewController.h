//
//  DetailViewController.h
//  TUCMP300MAP
//
//  Created by Shirleen Kneppers on 20/04/2014.
//  Copyright (c) 2014 Shirleen Kneppers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)dropPin:(id)sender;
- (IBAction)clearPin:(id)sender;


@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
