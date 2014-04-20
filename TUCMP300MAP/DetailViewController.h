//
//  DetailViewController.h
//  TUCMP300MAP
//
//  Created by Shirleen Kneppers on 20/04/2014.
//  Copyright (c) 2014 Shirleen Kneppers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
